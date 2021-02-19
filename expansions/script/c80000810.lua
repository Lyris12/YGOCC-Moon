--bigboi rune--

local m=80000810
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	local RUNICS2=Effect.CreateEffect(c)
	RUNICS2:SetType(EFFECT_TYPE_IGNITION)
	RUNICS2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	RUNICS2:SetRange(LOCATION_EXTRA)
	RUNICS2:SetTarget(cm.runicmattg)
	RUNICS2:SetOperation(cm.runicmatop)
	c:RegisterEffect(RUNICS2)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80000810,0))
	e4:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_XMATERIAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetTarget(cm.target)
	e4:SetOperation(cm.copy)
	c:RegisterEffect(e4)
end

function cm.runicmatfilter(c)
	c:AddRuneslots(0)
	return c:IsFaceup() and c:GetRuneslots()>0 and c:IsSetCard(0xfe0)
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

function cm.copytg(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsSetCard(0xfe9)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.copytg,tp,0x74,0,1,nil,tp) end
end

function cm.copy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,cm.copytg,tp,0x74,0x74,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.HintSelection(g)
	c:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
end

