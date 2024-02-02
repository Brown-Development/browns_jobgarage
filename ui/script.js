$(document).ready(function () {
    $('#veh-mod').hide()
    $('#veh-sel').hide()
    $('#return').hide()
    $('#continue').hide()
    $('#cancel').hide()
    $('#slide').hide()
    $('#load').hide()

    let cosmetic = false;
    let performance = false;

    let passed = 0;
    let anim = false;

    let max = [];

    let extras = [];

    let colors = {
        'Classic': 75,
        'Metallic': 75,
        'Pearl': 74,
        'Matte': 20,
        'Metal': 5,
        'Chrome': 1
    };

    let prim_int = 75
    let sec_int = 75
    

    $('#return').click(function() {
        if (!anim) {
            transform('sel')
        }
    })

    $('#continue').click(function() {
        if (!anim) {
            transform('continue')
        }
    })

    $('#cancel').click(function() {
        if (!anim) {
            transform('close')
        }
    })

    $('#return').hover(function () {
        $('#return').css('color', 'white')
    }, function () {
        $('#return').css('color', 'silver')
    })

    $('#continue').hover(function () {
        $('#continue').css('color', 'white')
    }, function () {
        $('#continue').css('color', 'silver')
    })

    $('#cancel').hover(function () {
        $('#cancel').css('color', 'white')
    }, function () {
        $('#cancel').css('color', 'silver')
    })


    $('.veh-cont').hover(function() {
        $(this).css('background-color', 'white')
    }, function() {
        $(this).css('background-color', 'silver')
    })

    function ResetAll() {
        $('.sel-int').text(0)
        prim_int = 75
        sec_int = 75
        max = [];
        extras = [];
        passed = 0
        anim = false
        $('#cancel').css('animation', 'slide-down-3 1s forwards');
        $('#veh-sel').css('animation', 'slide-in 1s forwards');
        $('#return').css('animation', '');
        $('#continue').css('animation', '');
        $('#veh-mod').css('animation', '');
        $.post('http://browns_jobgarage/ChangeMaterial', JSON.stringify({
            type: 'primary',
            material: 'Metallic'
        }))
        $.post('http://browns_jobgarage/ChangeMaterial', JSON.stringify({
            type: 'secondary',
            material: 'Metallic'
        }))
    }

    function transform(t) {

        anim = true

        switch (t) {
            case 'mods':
                $.post('http://browns_jobgarage/ControlSlide', JSON.stringify({
                    toggle: true
                }))
                $('#slide').css('animation', 'slide-down-4 1s forwards');
                $('#veh-sel').css('animation', 'slide-out 1s forwards');
                $('#return').css('animation', 'slide-down 1s forwards');
                $('#continue').css('animation', 'slide-down-2 1s forwards');
                $('#veh-mod').css('animation', 'slide-in 1s forwards');
                $('#cancel').css('animation', 'slide-up-3 1s forwards');
                $('#return').show()
                $('#continue').show()
                $('#veh-mod').show()
                $('#slide').show()
                $('.sel-int').text(0)
                if (cosmetic) {
                    $('#cosmetic').show()
                }
                if (performance) {
                    $('#performance').show()
                }
                prim_int = 75
                sec_int = 75
                extras = [];
                setTimeout(() => {
                    anim = false
                }, 1000);

                break;
            case 'sel':
                $.post('http://browns_jobgarage/ControlSlide', JSON.stringify({
                    toggle: false
                }))
                $('#slide').css('animation', 'slide-up-4 1s forwards');
                $('#veh-mod').css('animation', 'slide-out 1s forwards');
                $('#return').css('animation', 'slide-up 1s forwards');
                $('#continue').css('animation', 'slide-up-2 1s forwards');
                $('#veh-sel').css('animation', 'slide-in 1s forwards');
                $('#cancel').css('animation', 'slide-down-3 1s forwards');
                prim_int = 75
                sec_int = 75
                extras = [];
                setTimeout(() => {
                    anim = false
                }, 1000);
                break
            case 'continue':
                $('#slide').css('animation', 'slide-up-4 1s forwards');
                $('#veh-mod').css('animation', 'slide-out 1s forwards');
                $('#return').css('animation', 'slide-up 1s forwards');
                $('#continue').css('animation', 'slide-up-2 1s forwards');
                setTimeout(() => {
                    anim = false
                    $('#veh-mod').hide()
                    $('#veh-sel').hide()
                    $('#return').hide()
                    $('#continue').hide()
                    $('#cancel').hide()
                    $('#slide').hide()
                    ResetAll()
                    $.post('http://browns_jobgarage/Continue')
                    $('#veh-sel').empty();
                }, 200);
                break
            case 'close':
                $('#cancel').css('animation', 'slide-up-3 1s forwards')
                $('#veh-sel').css('animation', 'slide-out 1s forwards');
                setTimeout(() => {
                    anim = false
                    $('#veh-mod').hide()
                    $('#veh-sel').hide()
                    $('#return').hide()
                    $('#continue').hide()
                    $('#cancel').hide()
                    $('#slide').hide()
                    ResetAll()
                    $.post('http://browns_jobgarage/Close')
                    $('#veh-sel').empty();
                }, 200);
                break
            case 'takehome':
                $.post('http://browns_jobgarage/ControlSlide', JSON.stringify({
                    toggle: true
                }))
                $('#slide').css('animation', 'slide-down-4 1s forwards');
                $('#veh-sel').css('animation', 'slide-out 1s forwards');
                $('#continue').css('animation', 'slide-down-2 1s forwards');
                $('#veh-mod').css('animation', 'slide-in 1s forwards');
                $('#cancel').css('animation', 'slide-up-3 1s forwards');
                $('#continue').show()
                $('#veh-mod').show()
                $('#slide').show()
                $('.sel-int').text(0)
                prim_int = 75
                sec_int = 75
                extras = [];
                setTimeout(() => {
                    anim = false
                }, 1000);

                break;
            default:
                break;
        }
    }

    function CreateVehicleMenu(model, label, count, job) {

        passed += 1
        
        let btn = document.createElement('button')

        btn.className = 'veh-cont'

        $(btn).text(label)

        $(btn).hover(function () {
            if (!anim) {
                $(btn).css('background-color', 'white')
                $.post('http://browns_jobgarage/ChangeVehicle', JSON.stringify({
                    model: model,
                    job: job
                }))
            }
            }, function () {
                $(btn).css('background-color', 'silver')
            }
        );

        $(btn).click(function() {
            if (!anim) {
                $.post('http://browns_jobgarage/ChangeVehicle', JSON.stringify({
                    model: model,
                    job: job
                }))
                if (cosmetic | performance) {
                    transform('mods')
                } else {
                    transform('continue')
                }
            }
        })

        $('#veh-sel').append(btn);

        if (passed == count) {
            $('#veh-sel').show()
            $('#cancel').show()
            passed = 0;
        }
    }

    $('.extra-btn').hover(function() {
        $(this).css('background-color', 'silver')
    }, function() {
        $(this).css('background-color', 'black')
    })

    $('.extra-btn').click(function() {
        var int = $(this).text()
        var key = `extra${int}`

        switch (extras[key]) {
            case undefined: 
                extras[key] = true 
                break
            case false:
                extras[key] = true 
                break
            case true:
                extras[key] = false 
                break 
            default:
                extras[key] = true 
                break
        }

        $.post('http://browns_jobgarage/ChangeExtra', JSON.stringify({
            extra: int,
            toggle: extras[key]
        }))
    })

    window.addEventListener('message', function(event) {
        if (event.data.type === 'vehicles') {
            let data = event.data 
            CreateVehicleMenu(data.model, data.label, data.count, data.job)
        }
    })

    $('.mod-int-btn-left').click(function() {
        var id = $(this).attr('id')
        var trash = 'left-'
        var result = id.slice(trash.length)
        var maxInt = max[result];

        var intHandler = parseInt($(`#int-${result}`).text(), 10)

        let newValue = intHandler

        newValue = newValue - 1 

        if (newValue < 0) {
            $(`#int-${result}`).text(maxInt)
            newValue = maxInt
        } else  {
            $(`#int-${result}`).text(newValue)
            newValue = newValue
        }

        $.post('http://browns_jobgarage/ChangeMod', JSON.stringify({
            mod: result, 
            int: newValue
        }))

    })

    $('.mod-int-btn-right').click(function() {
        var id = $(this).attr('id')
        var trash = 'right-'
        var result = id.slice(trash.length)
        var maxInt = max[result];

        var intHandler = parseInt($(`#int-${result}`).text(), 10)

        let newValue = intHandler

        newValue = newValue + 1 

        if (newValue > maxInt) {
            $(`#int-${result}`).text(0)
            newValue = 0
        } else  {
            $(`#int-${result}`).text(newValue)
            newValue = newValue
        }


        $.post('http://browns_jobgarage/ChangeMod', JSON.stringify({
            mod: result, 
            int: newValue
        }))

    })

    $('.col-prim-int-btn-left').click(function() {
        var int = parseInt($('#int-col-prim').text(), 10)

        let newValue = int - 1 

        if (newValue < 0) {
            $('#int-col-prim').text(prim_int)
            newValue = prim_int
        } else {
            $('#int-col-prim').text(newValue)
            newValue = newValue
        }

        $.post('http://browns_jobgarage/ChangeColor', JSON.stringify({
            type: 'primary', 
            rgb: newValue
        }))

    })

    $('.col-prim-int-btn-right').click(function() {
        var int = parseInt($('#int-col-prim').text(), 10)

        let newValue = int + 1 

        if (newValue > prim_int) {
            $('#int-col-prim').text(0)
            newValue = 0
        } else {
            $('#int-col-prim').text(newValue)
            newValue = newValue
        }

        $.post('http://browns_jobgarage/ChangeColor', JSON.stringify({
            type: 'primary', 
            rgb: newValue
        }))

    })

    $('.col-sec-int-btn-left').click(function() {
        var int = parseInt($('#int-col-sec').text(), 10)

        let newValue = int - 1 

        if (newValue < 0) {
            $('#int-col-sec').text(sec_int)
            newValue = sec_int
        } else {
            $('#int-col-sec').text(newValue)
            newValue = newValue
        }

        $.post('http://browns_jobgarage/ChangeColor', JSON.stringify({
            type: 'secondary', 
            rgb: newValue
        }))

    })

    $('.col-sec-int-btn-right').click(function() {
        var int = parseInt($('#int-col-sec').text(), 10)

        let newValue = int + 1 

        if (newValue > sec_int) {
            $('#int-col-sec').text(0)
            newValue = 0
        } else {
            $('#int-col-sec').text(newValue)
            newValue = newValue
        }

        $.post('http://browns_jobgarage/ChangeColor', JSON.stringify({
            type: 'secondary', 
            rgb: newValue
        }))

    })

    $('.dropdown-item.prim').click(function() {
        var mat = $(this).text()

        prim_int = colors[mat]

        $('#int-col-prim').text(0)

        $.post('http://browns_jobgarage/ChangeMaterial', JSON.stringify({
            type: 'primary',
            material: mat
        }))
    })

    $('.dropdown-item.sec').click(function() {
        var mat = $(this).text() 

        sec_int = colors[mat]
        
        $('#int-col-sec').text(0)

        $.post('http://browns_jobgarage/ChangeMaterial', JSON.stringify({
            type: 'secondary',
            material: mat
        }))
    })

    $('#slide-left').mousedown(function() {
        $.post('http://browns_jobgarage/Slide', JSON.stringify({
            type: '-',
            toggle: true
        }))
    })

    $('#slide-left').mouseup(function() {
        $.post('http://browns_jobgarage/Slide', JSON.stringify({
            type: '-',
            toggle: false
        }))
    })

    $('#slide-right').mousedown(function() {
        $.post('http://browns_jobgarage/Slide', JSON.stringify({
            type: '+',
            toggle: true
        }))
    })

    $('#slide-right').mouseup(function() {
        $.post('http://browns_jobgarage/Slide', JSON.stringify({
            type: '+',
            toggle: false
        }))
    })

    window.addEventListener('message', function(event) {
        if (event.data.type === 'data') {
            extras = []
            max = event.data.data
        }
    })

    window.addEventListener('message', function(event) {
        if (event.data.type === 'customs') {
            let data = event.data 

            cosmetic = data.cosmetic
            performance = data.performance

            if (!cosmetic) {
                $('#cosmetic').hide()
            }
            if (!performance) {
                $('#performance').hide()
            }
        }
    })

    window.addEventListener('message', function(event) {
        if (event.data.type == 'takehome') {
            transform('takehome')
        }
    })

    window.addEventListener('message', function(e) {
        if (e.data.type === 'progress') {
            $('#load-veh').text('')
            $('#load').show()

        }
    })

    window.addEventListener('message', function(e) {
        if (e.data.type === 'loading') {
            let data = e.data
            $('#load-veh').text(data.veh)
        }
    })

    window.addEventListener('message', function(e) {
        if (e.data.type === 'hide_progress') {
            $('#load-veh').text('')
            $('#load').hide()
        }
    })
    
});