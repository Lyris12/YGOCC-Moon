--True White Hell Experience
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetTarget(s.target)
		e1:SetOperation(s.activate)
		c:RegisterEffect(e1)
		--matcheck
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_MATERIAL_CHECK)
		e2:SetValue(s.valcheck)
		c:RegisterEffect(e2)
end
	function s.ffilter(c)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsFaceup() and c:GetFlagEffect(502242)~=0
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ffilter(chkc,nil) end
	if chk==0 then return Duel.IsExistingTarget(s.ffilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.ffilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,3000)
end
	function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local tc1=tc:GetEquipGroup():IsExists(Card.IsCode,1,nil,49306994)
	if tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,REASON_EFFECT) and not e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,49306994) then
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Remove(g,REASON_EFFECT)
	else
		if tc:GetEquipGroup():IsExists(Card.IsCode,1,nil,49306994) then
			if Duel.Remove(tc,REASON_EFFECT) then
			Duel.Damage(3000,tp-1,REASON_EFFECT) end
			end
		end
	end
end
	function s.valcheck(e,c)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local lg=g:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT,c,SUMMON_TYPE_FUSION)
	if #g==#lg then
		c:RegisterFlagEffect(502242,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
	