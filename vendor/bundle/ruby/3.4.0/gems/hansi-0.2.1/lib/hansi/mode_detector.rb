require 'shellwords'

module Hansi
  class ModeDetector
    TERMS = { # only includes $TERM values that don't have the color amout in ther name and support more than 8 colors
      0  => ["dummy"],
      15 => ["emu"],
      16 => [
        "amiga-vnc", "d430-dg", "d430-unix", "d430-unix-25", "d430-unix-s", "d430-unix-sr", "d430-unix-w", "d430c-dg", "d430c-unix", "d430c-unix-25",
        "d430c-unix-s", "d430c-unix-sr", "d430c-unix-w", "d470", "d470-7b", "d470-dg", "d470c", "d470c-7b", "d470c-dg", "dg+color", "dg+fixed", "dgmode+color",
        "dgunix+fixed", "hp+color", "hp2397", "hp2397a", "ncr260wy325pp", "ncr260wy325wpp", "ncr260wy350pp", "ncr260wy350wpp", "nsterm+c", "nsterm-7-c",
        "nsterm-7-c-s", "nsterm-acs-c", "nsterm-acs-c-s", "nsterm-c", "nsterm-c-7", "nsterm-c-acs", "nsterm-c-s", "nsterm-c-s-7", "nsterm-c-s-acs"
      ],
      52 => [
        "d430-dg-ccc", "d430-unix-25-ccc", "d430-unix-ccc", "d430-unix-s-ccc", "d430-unix-sr-ccc", "d430-unix-w-ccc", "d430c-dg-ccc", "d430c-unix-25-ccc",
        "d430c-unix-ccc", "d430c-unix-s-ccc", "d430c-unix-sr-ccc", "d430c-unix-w-ccc", "dg+ccc", "dgunix+ccc"
      ],
      64 => [
        "hpterm-color", "wy370", "wy370-101k", "wy370-105k", "wy370-EPC", "wy370-nk", "wy370-rv", "wy370-vb", "wy370-w", "wy370-wvb", "wyse370"
      ],
      256 => ["Eterm"]
    }

    TRUE_COLOR_COMMANDS = [ "finalterm", "konsole", "sakura", "roxterm", "yakuake", "st", "tilda" ]
    COMMANDS = [
      "gnome-terminal", "gnome-terminal-server", "xterm", "iTerm2", "guake", "termit", "evilvte", "terminator",
      "lxterminal", "terminology", "xfce4-terminal", "stjerm", *TRUE_COLOR_COMMANDS
    ]

    attr_reader :env, :supported, :io
    def initialize(env, shell_out: nil, io: nil, supported: [0, 8, 16, 88, 256, Hansi::TRUE_COLOR])
      shell_out = true    if shell_out.nil? and env == ENV
      io        = $stdout if io.nil?        and env == ENV
      @env, @shell_out, @supported , @io = env, shell_out, supported, io
    end

    def mode
      @mode  ||= begin
        mode   = from_tput || from_term_program || from_term
        mode   = Hansi::TRUE_COLOR if mode == 256 and maximum >= Hansi::TRUE_COLOR and true_color?
        mode ||= 8 if io and io.tty?
        mode ||= 0
        supported?(mode) ? mode : minimum
      end
    end

    def from_tput
      return unless shell_out?
      colors = `tput #{"-T#{term}" if term} colors`.to_i
      colors if colors > 8
    rescue Errno::ENOENT
    end

    def from_term_program
      term_program = env['TERM_PROGRAM']
      256 if term_program == 'Apple_Terminal' or term_program == 'MacTerm'
    end

    def from_term
      case term
      when /[\-\+](\d+)color/ then $1.to_i
      when /[\-\+](\d+)bit/   then 2 ** $1.to_i
      when /[\-\+](\d+)byte/  then 2 ** (8*$1.to_i)
      when 'xterm'            then from_xterm
      else TERMS.keys.detect { |key| TERMS[key].include? term }
      end
    end

    def from_xterm
      terminal_command ? 256 : 16
    end

    def term
      env['TERM']
    end

    def true_color?
      return true              if TRUE_COLOR_COMMANDS.include? terminal_command
      return iterm_true_color? if iterm?
      return xterm_true_color? if actual_xterm?
      return gnome_true_color? if gnome_terminal?
      false
    end

    def gnome_terminal?
      terminal_command == "gnome-terminal" or terminal_command == "gnome-terminal-server"
    end

    def actual_xterm?
      terminal_command == "xterm"
    end

    def iterm?
      env.include? 'ITERM_SESSION_ID' or env['TERM_PROGRAM'] == 'iTerm.app' or terminal_command == 'iTerm2'
    end

    def xterm_true_color?
      `xterm -version`[/\d+/].to_i >= 282
    rescue Errno::ENOENT
      false
    end

    def gnome_true_color?
      major, minor = `gnome-terminal --version`[/\d+\.\d+/].split(?.).map(&:to_i)
      major == 3 ? minor > 11 : major > 3
    rescue Errno::ENOENT
      false
    end

    def iterm_true_color?
      return false unless iterm_version
      major, minor, patch = iterm_version.split('.').map(&:to_i)
      if major == 2 and minor == 9
        patch > 20130908
      else
        major >= 3
      end
    end

    def iterm_version
      @iterm_version ||= env['TERM_PROGRAM_VERSION']
      @iterm_version ||= if shell_out? and iterm_path = commands.detect { |c| c["Contents/MacOS/iTerm"] }
        iterm_path = iterm_path[/^(.*) [^ ]+$/, 1] while iterm_path and not File.exist?(iterm_path)
        info_path  = File.expand_path('../../Info.plist', iterm_path)
        `defaults read #{Shellwords.escape(info_path)} CFBundleVersion`.chomp if File.exist?(info_path) and system 'which defaults >/dev/null'
      end
    rescue Errno::ENOENT
    end

    def terminal_command(command = full_terminal_command)
      command &&= File.basename(command)
      command &&= command[/\S+/]
      command
    end

    def full_terminal_command
      commands.detect do |command|
        command = terminal_command(command)
        COMMANDS.include?(command) or command == env['TERM_PROGRAM']
      end
    end

    def commands
      @commands ||= begin
        commands  = []
        pid       = Process.pid
        processes = self.processes
        while pid and processes.include? pid
          commands << processes[pid][:command]
          pid = processes[pid][:ppid]
        end
        commands
      end
    end

    def processes
      return {} unless shell_out?
      @processes ||= begin
        ps = `ps -A -o pid,ppid,command`.scan(/^\s*(\d+)\s+(\d+)\s+(.+)$/)
        Hash[ps.map { |pid, ppid, command| [pid.to_i, ppid: ppid.to_i, command: command] }]
      end
    rescue Errno::ENOENT
      {}
    end

    def shell_out?
      @shell_out and not windows?
    end

    def windows?
      File::ALT_SEPARATOR == "\\"
    end

    def supported?(value)
      case supported
      when Array       then supported.include? value
      when true, false then supported
      when Integer     then supported == value
      else false
      end
    end

    def maximum
      case supported
      when Array       then supported.max
      when true        then 1/0.0
      when Integer     then supported
      else 0
      end
    end

    def minimum
      case supported
      when Array       then supported.min
      when true        then 8
      when Integer     then supported
      else 0
      end
    end
  end
end
