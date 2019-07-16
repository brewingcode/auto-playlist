export default
  methods:
    scrollDown: (index) ->
      if index <= @current
        throw new Error "scrollDown called with index (#{index}) l.t.e. than this.current (#{@current})"
      # console.log "scrollDown: #{@current} -> #{index}"
      @current = index
      if @current > @tracks.length - 1
        # wrapped around the bottom, scroll to very top of page
        @current = 0
        document.querySelector('body').scrollIntoView()
      else
        # check if row is below viewport, and scroll if needed
        el = document.querySelector("tr:nth-child(#{@current + 1})")
        h = window.innerHeight or document.documentElement.clientHeight
        if el?.getBoundingClientRect().bottom > h
          el.scrollIntoView(false)

      @setCurrent()

    scrollUp: (index) ->
      if index >= @current
        throw new Error "scrollUp called with index (#{index}) g.t.e. than this.current (#{@current})"
      # console.log "scrollUp: #{@current} -> #{index}"
      @current = index
      if @current < 0
        # wrapped around the top, scroll to bottom
        @current = @tracks.length - 1
        document.querySelector('tr:last-child').scrollIntoView()
      else
        # check if the row is above viewport, and scroll if needed
        el = document.querySelector("tr:nth-child(#{@current + 1})")
        h = window.innerHeight or document.documentElement.clientHeight
        if el?.getBoundingClientRect().top < 0
          el.scrollIntoView()

      @setCurrent()

    # tell Vue about the current row
    setCurrent: ->
      @tracks.forEach (t, i) =>
        if i is @current
          t.selected = true
          @$set @tracks, i, t
        else if t.selected is true
          t.selected = false
          @$set @tracks, i, t
