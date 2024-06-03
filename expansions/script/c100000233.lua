--[[
The Figure in the Mirror
La Figura nello Specchio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddIllusionBattleEffect(c)
	--[[If this card is Normal or Special Summoned, or if your opponent Special Summons a monster(s) in the same column as a face-up Continuous Trap(s) you control: You can target 1 face-up monster your opponent controls; place it in your opponent's Spell & Trap Zone as a Continuous Trap with the following effect.
	● Monsters you control in the same column as this card lose 400 ATK/DEF for each face-up Continuous Trap you control.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	local MZChk=aux.AddThisCardInMZoneAlreadyCheck(c)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(MZChk)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--While your opponent controls 3 or more face-up Continuous Traps, negate the effects of all face-up monsters your opponent controls, except monsters in the Extra Monster Zone.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsInEMZ)))
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,p)
	return c:IsSummonPlayer(1-p) and c:GetColumnGroup():IsExists(s.columnfilter,1,c,p)
end
function s.columnfilter(c,p)
	return c:IsFaceup() and c:IsControler(tp) and c:IsTrap(TYPE_CONTINUOUS)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)>0 and Duel.IsExists(true,Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) and (tc:IsControler(1-tp) or tc:IsAbleToChangeControler()) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_SZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.atktg)
		e1:SetValue(s.atkval)
		local e2=e1:UpdateDefenseClone(c)
		Duel.PlaceAsContinuousCard(tc,tp,1-tp,c,TYPE_TRAP,aux.Stringid(id,1),e1,e2)
	end
end
function s.atktg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsTrap,TYPE_CONTINUOUS),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-400
end

--E3
function s.discon(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsTrap,TYPE_CONTINUOUS),e:GetHandlerPlayer(),0,LOCATION_ONFIELD,nil)>=3
end