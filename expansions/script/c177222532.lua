--Dimensional Gate Guardian
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,12,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--If this card is Time Leap Summoned: You can target up to 1 each LIGHT, WIND and WATER monsters that are banished or in your GY; equip them to this card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--● LIGHT: Once per turn (Quick Effect): You can discard 1 card, then target 1 face-up card on the field; destroy it.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--● WIND: Your opponent cannot target this card with monster effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--● WATER: All monsters your opponent controls lose 500 ATK/DEF.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(-500)
	e4:SetCondition(s.atkdowncon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
function s.sumcon(e,c)
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=11
end
function s.tlfilter(c,e,mg)
	local ef=e:GetHandler():GetFuture()
	return c:GetOriginalLevel()==11
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.eqfilter(c)
	return c:IsMonster() and not c:IsForbidden() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_WIND) or c:IsAttribute(ATTRIBUTE_WATER))
end
function s.eqfilter2(g,ft)
	return #g<=ft
		and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)<=1
		and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)<=1
		and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)<=1
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	local c=e:GetHandler()
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	if chk==0 then return ft>0
		and Duel.IsExistingTarget(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if sg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local rg=sg:SelectSubGroup(tp,s.eqfilter2,false,1,3,ft)
	Duel.SetTargetCard(rg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,rg,#rg,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 then return end
		if g:GetCount()>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			g=g:Select(tp,ft,ft,nil)
		end
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				Duel.Equip(tp,tc,c,true,true)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			Duel.EquipComplete()
		end
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.descon(e)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup()
	return #eg>0 and eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.tgcon(e)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup()
	return #eg>0 and eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
end
function s.atkdowncon(e)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup()
	return #eg>0 and eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end