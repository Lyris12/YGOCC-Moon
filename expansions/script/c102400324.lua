local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1000)
	e2:SetLabel(0)
	e2:SetLabelObject(e1)
	e2:SetCost(function() e2:SetLabel(1) return true end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(id)
end
function s.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(Card.IsRace,1,nil,RACE_CYBERSE) and not mg:IsExists(s.exmfilter,1,nil)
end
function s.LExtraFilter(c,lc,tp)
	if c:IsLocation(LOCATION_ONFIELD) and c:IsFacedown() or not c:IsCanBeLinkMaterial(lc) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		local tf=te:GetValue()
		local related,valid=tf(te,lc,nil,c,tp)
		if c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) or related then return true end
	end
	return false
end
function s.cfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,c,e,tp)
end
function s.filter(c,e,tp)
	local tc=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD,nil,c,tp)
	if tc:IsCanBeLinkMaterial(c) and s.matval(e:GetLabelObject(),c,nil,tc,tp) then g:AddCard(tc) end
	return tc:IsCanBeLinkMaterial(c) and c:IsRace(RACE_CYBERSE) and c:IsLinkSummonable(g,tc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkc=e:GetLabel()~=0
	if chk==0 then e:SetLabel(0) return chkc and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp),POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then Duel.LinkSummon(tp,tc,nil) end
end
