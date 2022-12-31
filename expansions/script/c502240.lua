--Justice Forces of Light & Truth
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		c:RegisterEffect(e1)
		-- add
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1,id)
		e2:SetCondition(s.cond)
		e2:SetTarget(s.thtg)
		e2:SetOperation(s.thop)
		c:RegisterEffect(e2)
		--destroy replace
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_DESTROY_REPLACE)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTarget(s.reptg)
		e3:SetValue(s.repval)
		e3:SetOperation(s.repop)
		c:RegisterEffect(e3)	
end
	function s.thcfilter(c)
	return c:IsFacedown() or c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_DARK+ATTRIBUTE_DIVINE+ATTRIBUTE_EARTH+ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
end
	function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_MZONE,0,1,nil) 
end
	function s.thfilter(c)
	return c:IsCode(502233) and c:IsAbleToHand()
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT)))
	e1:SetValue(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	Duel.RegisterEffect(e4,tp)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e6:SetTargetRange(0xff,0xff)
	e6:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT)))
	e6:SetValue(s.limit)
	e6:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e6,tp)
end
	function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
	function s.limit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and c:IsCanBeRitualMaterial()
end
	function s.desfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:GetCode()==49306994
end
	function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_FUSION)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
	function s.wfilter(c,e,tp)
	return c:IsCode(49306994) and c:IsFaceup() and c:IsControler(tp) and c:IsSSetable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
	function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.wfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
			if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
					local g=Duel.SelectMatchingCard(tp,s.wfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
					e:SetLabelObject(g:GetFirst())
					return true
			end
			return false
end
	function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
	function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.ChangePosition(tc,POS_FACEDOWN)
end