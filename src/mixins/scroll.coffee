# requires the following properties on the parent component:
#   - this.selectedIndex: int, 0-based index of the selected row
#   - this.tracks: array of track objects

export default
  methods:
    scrollDown: (index) ->
      if index < @selectedIndex
        throw new Error "scrollDown called with index (#{index}) l.t. than this.selectedIndex (#{@selectedIndex})"
      else if index == @selectedIndex
        return
      # console.log "scrollDown: #{@selectedIndex} -> #{index}"
      @selectedIndex = index
      if @selectedIndex > @tracks.length - 1
        # wrapped around the bottom, scroll to very top of page
        @selectedIndex = 0
        document.querySelector('body').scrollIntoView()
      else
        # check if row is below viewport, and scroll if needed
        el = document.querySelector(".tracks tbody tr:nth-child(#{@selectedIndex + 1})")
        h = window.innerHeight or document.documentElement.clientHeight
        if el?.getBoundingClientRect().bottom > h
          el.scrollIntoView(false)

      @setCurrent()

    scrollUp: (index) ->
      if index > @selectedIndex
        throw new Error "scrollUp called with index (#{index}) g.t. than this.selectedIndex (#{@selectedIndex})"
      else if index == @selectedIndex
        return
      # console.log "scrollUp: #{@selectedIndex} -> #{index}"
      @selectedIndex = index
      if @selectedIndex < 0
        # wrapped around the top, scroll to bottom
        @selectedIndex = @tracks.length - 1
        document.querySelector('.tracks tbody tr:last-child').scrollIntoView()
      else
        # check if the row is above viewport, and scroll if needed
        el = document.querySelector(".tracks tbody tr:nth-child(#{@selectedIndex + 1})")
        h = window.innerHeight or document.documentElement.clientHeight
        if el?.getBoundingClientRect().top < 0
          el.scrollIntoView()

      @setCurrent()

    # tell Vue about the current row
    setCurrent: ->
      if @selectedIndex > @tracks.length - 1
        @selectedIndex = @tracks.length - 1
      @tracks.forEach (t, i) =>
        if i is @selectedIndex
          t.selected = true
          @$set @tracks, i, t
        else if t.selected is true
          t.selected = false
          @$set @tracks, i, t
