--Verglascent's Rune of Decay
local id=81000801
local m=81000801
local cm=_G["c"..id]
local cid=_G["c"..id]

function cm.initial_effect(c)
	Auxiliary.I_Am_Runic(c)

	local RUNICS2=Effect.CreateEffect(c)
	RUNICS2:SetType(EFFECT_TYPE_IGNITION)
	RUNICS2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	RUNICS2:SetRange(LOCATION_EXTRA)
	RUNICS2:SetTarget(cm.runicmattg)
	RUNICS2:SetOperation(cm.runicmatop)
	c:RegisterEffect(RUNICS2)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80000810,0))
	e4:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_XMATERIAL)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetTarget(cm.target)
	e4:SetOperation(cm.operation)
	c:RegisterEffect(e4)

end

function cm.runicmatfilter(c)
	c:AddRuneslots(0)
	return c:IsFaceup() and c:GetRuneslots()>0 -- and c:IsSetCard(0xfe0)
end

function cm.runicmattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and cm.runicmatfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		and Duel.IsExistingTarget(cm.runicmatfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.runicmatfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end

function cm.runicmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
		tc:RemoveRuneslots(1)
	end
end



function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_DRAW)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetOperation(cm.atkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e2=e3:Clone()
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		tc:RegisterEffect(e2)
		local e1=e3:Clone()
		e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
		tc:RegisterEffect(e1)
		local e4=e3:Clone()
		e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e4)
		local e5=e3:Clone()
		e5:SetCode(EVENT_PHASE+PHASE_MAIN2)
		tc:RegisterEffect(e5)
		local e6=e3:Clone()
		e6:SetCode(EVENT_PHASE+PHASE_END)
		tc:RegisterEffect(e6)
	end
end


function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-50)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1,true)
end
