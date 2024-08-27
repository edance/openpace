defmodule SqueezeWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component
  import SqueezeWeb.FormatHelpers

  alias Phoenix.HTML.{Form, FormField}

  @colors [
    "bg-gradient-to-tl from-blue-500 to-violet-500",
    "bg-gradient-to-tl from-red-500 to-orange-500",
    "bg-gradient-to-tl from-orange-500 to-yellow-500",
    "bg-gradient-to-tl from-yellow-500 to-green-500",
    "bg-gradient-to-tl from-green-500 to-teal-500",
    "bg-gradient-to-tl from-teal-500 to-cyan-500"
  ]

  def logo(assigns) do
    ~H"""
    <svg
      class={[@class]}
      viewBox="0 0 310 82"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
    >
      <g id="Logo" stroke="none" stroke-width="1" fill-rule="evenodd">
        <path
          d="M80.975,21.765 C85.3383551,21.765 88.986652,23.3049846 91.92,26.385 C94.853348,29.4650154 96.32,34.1674684 96.32,40.4925 C96.32,46.8175316 94.8625146,51.6024838 91.9475,54.8475 C89.0324854,58.0925162 85.0908582,59.715 80.1225,59.715 C75.1541418,59.715 71.2583475,58.1016828 68.435,54.875 C65.6116526,51.6483172 64.2,46.9550308 64.2,40.795 C64.2,37.4216498 64.6949951,34.4608461 65.685,31.9125 C66.675005,29.3641539 67.9766586,27.3933403 69.59,26 C72.8533496,23.1766526 76.6483117,21.765 80.975,21.765 Z M71.075,40.52 C71.075,49.6133788 74.2283018,54.16 80.535,54.16 C83.9083502,54.16 86.2733266,52.7666806 87.63,49.98 C88.8766729,47.523321 89.5,44.5166844 89.5,40.96 C89.5,37.769984 88.9500055,34.83668 87.85,32.16 C87.2266635,30.693326 86.2825063,29.5383376 85.0175,28.695 C83.7524937,27.8516624 82.1116768,27.43 80.095,27.43 C78.0783232,27.43 76.3458406,28.0899934 74.8975,29.41 C73.4491594,30.7300066 72.4500027,32.3249907 71.9,34.195 C71.3499973,36.0650093 71.075,38.1733216 71.075,40.52 Z M103.415,64.225 L103.415,37.605 C103.415,36.9816636 103.314168,36.5508345 103.1125,36.3125 C102.910832,36.0741655 102.553336,35.955 102.04,35.955 L99.73,35.79 L99.73,31.335 L109.025,31.335 L109.025,34.91 C109.61167,33.8099945 110.674992,32.8016713 112.215,31.885 C113.755008,30.9683288 115.588323,30.51 117.715,30.51 C124.3517,30.51 127.67,35.1666201 127.67,44.48 C127.67,49.4300248 126.588344,53.2249868 124.425,55.865 C122.261656,58.5050132 119.328352,59.825 115.625,59.825 C113.424989,59.825 111.463342,59.2933386 109.74,58.23 L109.74,65.82 L114.195,66.04 L114.195,70.385 L100.005,70.385 L100.005,66.205 L101.82,66.04 C102.370003,65.9666663 102.773332,65.8108345 103.03,65.5725 C103.286668,65.3341655 103.415,64.8850033 103.415,64.225 Z M120.85,45.03 C120.85,38.9066361 118.998352,35.845 115.295,35.845 C113.754992,35.845 112.444172,36.3124953 111.3625,37.2475 C110.280828,38.1825047 109.74,39.2916602 109.74,40.575 L109.74,53.225 C111.13334,54.1416713 112.829157,54.6 114.8275,54.6 C116.825843,54.6 118.329162,53.6833425 119.3375,51.85 C120.345838,50.0166575 120.85,47.7433469 120.85,45.03 Z M145.38,30.51 C148.130014,30.51 150.311659,31.17916 151.925,32.5175 C153.538341,33.85584 154.345,35.7349879 154.345,38.155 C154.345,39.7683414 153.99667,41.1891605 153.3,42.4175 C152.60333,43.6458395 151.741672,44.6083298 150.715,45.305 C149.688328,46.0016702 148.441674,46.5699978 146.975,47.01 C144.518321,47.743337 141.750015,48.11 138.67,48.11 C138.780001,50.053343 139.384995,51.6208274 140.485,52.8125 C141.585006,54.0041726 143.271655,54.6 145.545,54.6 C147.818345,54.6 150.091655,53.7933414 152.365,52.18 L154.455,56.635 C153.721663,57.2950033 152.484175,57.9733298 150.7425,58.67 C149.000825,59.3666702 147.011678,59.715 144.775,59.715 C140.301644,59.715 137.02001,58.4775124 134.93,56.0025 C132.83999,53.5274876 131.795,50.1266883 131.795,45.8 C131.795,41.4733117 132.986655,37.843348 135.37,34.91 C137.753345,31.976652 141.089979,30.51 145.38,30.51 Z M142.85,43.105 C144.206673,42.848332 145.453328,42.3075041 146.59,41.4825 C147.726672,40.6574959 148.295,39.6766724 148.295,38.54 C148.295,36.3033221 147.195011,35.185 144.995,35.185 C142.941656,35.185 141.365005,36.0008252 140.265,37.6325 C139.164995,39.2641748 138.560001,41.2166553 138.45,43.49 C140.063341,43.4533332 141.529993,43.3250011 142.85,43.105 Z M157.865,35.735 L157.865,31.335 L167.16,31.335 L167.16,34.91 C168.113338,33.5533265 169.378325,32.4808373 170.955,31.6925 C172.531675,30.9041627 174.236658,30.51 176.07,30.51 C178.856681,30.51 181.010826,31.307492 182.5325,32.9025 C184.054174,34.497508 184.815,36.8899841 184.815,40.08 L184.815,54.435 L187.95,54.6 L187.95,59 L174.86,59 L174.86,54.82 L176.675,54.655 C177.225003,54.5816663 177.628332,54.4258345 177.885,54.1875 C178.141668,53.9491655 178.27,53.5000033 178.27,52.84 L178.27,41.51 C178.27,39.4933233 177.958336,37.9991715 177.335,37.0275 C176.711664,36.0558285 175.529175,35.57 173.7875,35.57 C172.045825,35.57 170.661672,36.1199945 169.635,37.22 C168.608328,38.3200055 168.095,39.6216592 168.095,41.125 L168.095,54.435 L171.23,54.6 L171.23,59 L158.14,59 L158.14,54.82 L159.955,54.655 C160.505003,54.5816663 160.908332,54.4258345 161.165,54.1875 C161.421668,53.9491655 161.55,53.5000033 161.55,52.84 L161.55,37.605 C161.55,36.5049945 161.091671,35.9366668 160.175,35.9 L157.865,35.735 Z M191.14,59 L191.14,54.545 L192.955,54.38 C194.018339,54.2699995 194.55,53.7566712 194.55,52.84 L194.55,27.265 L191.415,27.1 L191.415,22.425 L207.145,22.425 C211.251687,22.425 214.450822,23.3874904 216.7425,25.3125 C219.034178,27.2375096 220.18,30.1249808 220.18,33.975 C220.18,37.8250193 218.878346,40.8224893 216.275,42.9675 C213.671654,45.1125107 210.225021,46.185 205.935,46.185 L201.26,46.185 L201.26,54.16 L206.54,54.325 L206.54,59 L191.14,59 Z M201.26,40.85 L205.22,40.85 C210.57336,40.85 213.25,38.6683551 213.25,34.305 C213.25,31.6649868 212.562507,29.914171 211.1875,29.0525 C209.812493,28.190829 207.621682,27.76 204.615,27.76 L201.26,27.76 L201.26,40.85 Z M248.34,32.435 L248.34,52.895 C248.34,53.4816696 248.440832,53.8849989 248.6425,54.105 C248.844168,54.3250011 249.201664,54.4533331 249.715,54.49 L251.475,54.6 L251.475,59 L242.73,59 L242.73,55.81 L242.565,55.755 C240.731657,58.3950132 238.220016,59.715 235.03,59.715 C231.289981,59.715 228.521676,58.5233452 226.725,56.14 C224.928324,53.7566548 224.03,50.4933541 224.03,46.35 C224.03,41.3633084 225.239988,37.4766806 227.66,34.69 C230.080012,31.9033194 233.709976,30.51 238.55,30.51 C241.666682,30.51 244.929983,31.1516603 248.34,32.435 Z M241.96,50.255 L241.96,36.01 C240.933328,35.533331 239.521676,35.295 237.725,35.295 C235.268321,35.295 233.490005,36.2849901 232.39,38.265 C231.289994,40.2450099 230.74,42.8666504 230.74,46.13 C230.74,52.0700297 232.646648,55.04 236.46,55.04 C238.073341,55.04 239.393328,54.5541715 240.42,53.5825 C241.446672,52.6108285 241.96,51.5016729 241.96,50.255 Z M261.485,44.865 C261.485,47.9816822 262.071661,50.401658 263.245,52.125 C264.418339,53.8483419 266.114156,54.71 268.3325,54.71 C270.550844,54.71 272.741656,53.9216745 274.905,52.345 L277.27,56.58 C274.666654,58.7066773 271.403353,59.77 267.48,59.77 C263.556647,59.77 260.467511,58.5325124 258.2125,56.0575 C255.957489,53.5824876 254.83,49.9250242 254.83,45.085 C254.83,40.2449758 256.122487,36.6058455 258.7075,34.1675 C261.292513,31.7291545 264.207484,30.51 267.4525,30.51 C270.697516,30.51 273.713319,31.2616591 276.5,32.765 L276.5,39.915 L271.44,40.3 L271.44,37.66 C271.44,36.669995 271.082504,36.0558345 270.3675,35.8175 C269.652496,35.5791655 268.910004,35.46 268.14,35.46 C263.703311,35.46 261.485,38.5949686 261.485,44.865 Z M294.54,30.51 C297.290014,30.51 299.471659,31.17916 301.085,32.5175 C302.698341,33.85584 303.505,35.7349879 303.505,38.155 C303.505,39.7683414 303.15667,41.1891605 302.46,42.4175 C301.76333,43.6458395 300.901672,44.6083298 299.875,45.305 C298.848328,46.0016702 297.601674,46.5699978 296.135,47.01 C293.678321,47.743337 290.910015,48.11 287.83,48.11 C287.940001,50.053343 288.544995,51.6208274 289.645,52.8125 C290.745006,54.0041726 292.431655,54.6 294.705,54.6 C296.978345,54.6 299.251655,53.7933414 301.525,52.18 L303.615,56.635 C302.881663,57.2950033 301.644175,57.9733298 299.9025,58.67 C298.160825,59.3666702 296.171678,59.715 293.935,59.715 C289.461644,59.715 286.18001,58.4775124 284.09,56.0025 C281.99999,53.5274876 280.955,50.1266883 280.955,45.8 C280.955,41.4733117 282.146655,37.843348 284.53,34.91 C286.913345,31.976652 290.249979,30.51 294.54,30.51 Z M292.01,43.105 C293.366673,42.848332 294.613328,42.3075041 295.75,41.4825 C296.886672,40.6574959 297.455,39.6766724 297.455,38.54 C297.455,36.3033221 296.355011,35.185 294.155,35.185 C292.101656,35.185 290.525006,36.0008252 289.425,37.6325 C288.324995,39.2641748 287.720001,41.2166553 287.61,43.49 C289.223341,43.4533332 290.689993,43.3250011 292.01,43.105 Z"
          id="OpenPace"
        >
        </path>
        <path
          d="M27.8156986,13 L51.6313972,26.75 L51.6313972,54.25 L27.8156986,68 L4,54.25 L4,26.75 L27.8156986,13 Z M11.0996492,45.4320988 C10.1144005,45.4320988 9.3156986,46.2308007 9.3156986,47.2160494 C9.3156986,48.2012981 10.1144005,49 11.0996492,49 L34.0468995,49 C35.0321482,49 35.8308501,48.2012981 35.8308501,47.2160494 C35.8308501,46.2308007 35.0321482,45.4320988 34.0468995,45.4320988 L11.0996492,45.4320988 Z M15.3420735,38.7160494 C14.3568247,38.7160494 13.5581228,39.5147513 13.5581228,40.5 C13.5581228,41.4852487 14.3568247,42.2839506 15.3420735,42.2839506 L38.2893237,42.2839506 C39.2745725,42.2839506 40.0732744,41.4852487 40.0732744,40.5 C40.0732744,39.5147513 39.2745725,38.7160494 38.2893237,38.7160494 L15.3420735,38.7160494 Z M19.5844977,32 C18.599249,32 17.8005471,32.7987019 17.8005471,33.7839506 C17.8005471,34.7691993 18.599249,35.5679012 19.5844977,35.5679012 L42.531748,35.5679012 C43.5169967,35.5679012 44.3156986,34.7691993 44.3156986,33.7839506 C44.3156986,32.7987019 43.5169967,32 42.531748,32 L19.5844977,32 Z"
          id="Combined-Shape"
          fill-rule="nonzero"
        >
        </path>
      </g>
    </svg>
    """
  end

  def wave_svg(assigns) do
    ~H"""
    <svg
      viewBox="0 0 2750 900"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
    >
      <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <path
          d="M0 200.526C139.289 118.304 246.452 77.1938 321.489 77.1938C434.043 77.1938 579.882 200.526 715.443 200.526C851.003 200.526 845.195 116.675 985.359 116.675C1125.52 116.675 1173.93 200.526 1321.3 200.526C1468.68 200.526 1468.68 77.1938 1562.04 77.1938C1655.39 77.1938 1698.02 135.722 1791.95 135.722C1885.87 135.722 1889.94 51 2023.78 51C2157.62 51 2241.57 246.001 2297.67 246.001C2353.78 246.001 2426.22 200.526 2486.52 200.526C2546.82 200.526 2543.79 246.001 2637.56 246.001C2700.07 246.001 2737.55 181 2750 51V900H0V200.526Z"
          fill="#825EE4"
          fill-opacity="0.0665195"
        />
        <path
          d="M0 123.265C3.27272 108.143 49.4079 100.582 138.406 100.582C271.902 100.582 423.459 179.328 512.284 179.328C601.109 179.328 609.296 167.014 713.792 167.014C818.288 167.014 847.5 200.212 1011.66 200.212C1175.82 200.212 1299.2 143.246 1428.07 143.246C1556.93 143.246 1587.43 200.212 1746.98 200.212C1906.53 200.212 1944.22 91.1191 2127.07 100.582C2309.93 110.045 2503.83 257.154 2582.07 257.154C2634.23 257.154 2690.2 219.184 2750 143.246V900H0L0 123.265Z"
          fill="#5E72E4"
          fill-opacity="0.104138"
        />
      </g>
    </svg>
    """
  end

  @doc """
  Renders a card.

  ## Examples

      <.card>
        This is a card.
      </.card>

  """

  attr :title, :string
  attr :subtitle, :string
  slot(:inner_block, required: true)

  def card(assigns) do
    ~H"""
    <div class="bg-slate-50 shadow-xl dark:bg-midnight dark:shadow-dark-xl rounded-lg mb-8 overflow-hidden">
      <%= if assigns[:title] do %>
        <div class="border-b border-gray-200 dark:border-slate-700 px-4 py-5 sm:px-6">
          <%= if assigns[:subtitle] do %>
            <h6 class="mb-0 uppercase text-gray-900 dark:text-white opacity-60 text-xs">
              <%= @subtitle %>
            </h6>
          <% end %>

          <h2 class="mb-0 text-md text-gray-900 dark:text-white">
            <%= @title %>
          </h2>
        </div>
      <% end %>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def icon(assigns) do
    ~H"""
    <span class={[assigns[:class], "iconify"]} data-icon={assigns.icon} data-inline="false" />
    """
  end

  def button(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-violet-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
        assigns[:class]
      ]}
      phx-click={assigns[:phx_click]}
      phx-value={assigns[:phx_value]}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def duration_input(assigns) do
    # given a value in seconds, convert it to hours, minutes, and seconds
    assigns =
      assigns
      |> assign_new(:hours, fn -> safe_div(assigns.value, 3600) end)
      |> assign_new(:minutes, fn -> safe_div(safe_rem(assigns.value, 3600), 60) end)
      |> assign_new(:seconds, fn -> safe_rem(assigns.value, 60) end)

    ~H"""
    <div class="flex items-center space-x-2 max-w-48">
      <input
        type="number"
        min="0"
        max="99"
        placeholder="hr"
        class="w-16 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        value={@hours}
      />
      <span class="font-medium">:</span>
      <input
        type="number"
        min="0"
        max="59"
        placeholder="min"
        class="w-16 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        value={@minutes}
      />
      <span class="font-medium">:</span>
      <input
        type="number"
        min="0"
        max="59"
        placeholder="sec"
        class="w-16 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        value={@seconds}
      />
    </div>
    """
  end

  attr :user, :map, required: true
  attr :class, :string, default: ""
  attr :size, :integer, default: 32
  attr :position, :string, default: "relative"

  def avatar(assigns) do
    base = "avatar flex items-center justify-center rounded-full overflow-hidden border-gray-300"

    assigns =
      assigns
      |> assign(class: "#{assigns[:class]} #{base}")
      |> assign_new(:bg_color, fn ->
        idx = rem(assigns.user.id, length(@colors))
        Enum.at(@colors, idx)
      end)
      |> assign_new(:border_size, fn ->
        if assigns.size < 48, do: 2, else: 4
      end)

    ~H"""
    <div
      class={[@class, @bg_color, @position]}
      style={"height: #{@size}px; width: #{@size}px; border-width: #{@border_size}px;"}
    >
      <span class="text-white font-semibold" style={"font-size: #{@size / 2}px;"}>
        <%= initials(@user) %>
      </span>

      <%= if @user.avatar do %>
        <img class="absolute top-0 bottom-0 right-0 left-0" alt={full_name(@user)} src={@user.avatar} />
      <% end %>
    </div>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot(:inner_block)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-2 text-sm leading-6 text-indigo-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-indigo-600 focus:ring-0"
          {@rest}
        />
        <span class="text-gray-800 dark:text-white text-sm">
          <%= @label %>
        </span>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 text-gray-800 dark:text-white bg-white dark:bg-white/10 dark:focus:bg-gray-700 shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-gray-800 dark:text-white bg-white dark:bg-white/10 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-gray-800 dark:text-white bg-white dark:bg-white/10 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-gray-500 dark:text-white/60">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="mt-2 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(SqueezeWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(SqueezeWeb.Gettext, "errors", msg, opts)
    end
  end

  defp safe_div(nil, _), do: nil
  defp safe_div(a, b), do: div(a, b)

  defp safe_rem(nil, _), do: nil
  defp safe_rem(a, b), do: rem(a, b)
end
