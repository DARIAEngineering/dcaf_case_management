import useFlash from "../useFlash";

describe("useFlash", () => {
  it("returns an object with the `render` function", () => {
    const flash = useFlash();
    expect(flash.render).not.toBeNull()
    expect(typeof(flash.render)).toEqual("function")
  })

  it("renders nothing if there is no text provided", () => {
    document.body.innerHTML = "<div id='flash'></div>"
    const flash = useFlash();
    flash.render()
    expect(document.body.innerHTML).not.toMatch(/alert/)
  })

  describe("rendering a 'notice' flash message", () => {
    it("updates the '#flash' element with an alert-success", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ notice: 'Abortion is a human right' })
      expect(document.body.innerHTML).toMatch(/alert-success/)
    })

    it("renders nothing if there is no text provided", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ notice: '' })
      expect(document.body.innerHTML).not.toMatch(/alert-success/)
    })
  })

  describe("rendering an 'alert' flash message", () => {
    it("updates the '#flash' element with an alert-danger", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ alert: 'Abortion is a human right' })
      expect(document.body.innerHTML).toMatch(/alert-danger/)
    })

    it("renders nothing if there is no text provided", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ alert: '' })
      expect(document.body.innerHTML).not.toMatch(/alert/)
    })
  })

  describe("rendering a 'danger' flash message", () => {
    it("updates the '#flash' element with an alert-danger", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ danger: 'Abortion is a human right' })
      expect(document.body.innerHTML).toMatch(/alert-danger/)
    })

    it("renders nothing if there is no text provided", () => {
      document.body.innerHTML = "<div id='flash'></div>"
      const flash = useFlash();
      flash.render({ danger: '' })
      expect(document.body.innerHTML).not.toMatch(/alert/)
    })
  })
});