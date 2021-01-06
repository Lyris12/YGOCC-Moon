--False Reality True God of Oblivion Dox
local s,id=GetID()
function s.initial_effect(c)
		--fusion material
		c:EnableReviveLimit()
		aux.AddFusionProcFunRep2(c,s.ffilter,3,63,true)
		--indes
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		--summon success
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_MATERIAL_CHECK)
		e2:SetValue(s.matcheck)
		c:RegisterEffect(e2)
end
	function s.ffilter(c,fc)
	return c:IsFusionSetCard(0x83e)
end 
	function s.matcheck(e,c)
	local ct=c:GetMaterial():GetCount()
	if ct>0 then
			local ae=Effect.CreateEffect(c)
			ae:SetType(EFFECT_TYPE_SINGLE)
			ae:SetCode(EFFECT_SET_ATTACK)
			ae:SetValue(ct*500)
			ae:SetReset(RESET_EVENT+0xff0000)
			c:RegisterEffect(ae)
			local de=ae:Clone()
			de:SetCode(EFFECT_SET_DEFENSE)
			c:RegisterEffect(de)
	end
	if ct>=3 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1,id)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			c:RegisterEffect(e1)
	end
	if ct>=5 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK+CATEGORY_RECOVER)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1,id+500)
			e1:SetCost(s.crost)
			e1:SetTarget(s.atktg)
			e1:SetOperation(s.atkop)
			c:RegisterEffect(e1)
	end
	if ct>=7 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetCategory(CATEGORY_TOGRAVE)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetCost(s.descost)
			e1:SetTarget(s.destg)
			e1:SetOperation(s.desop)
			c:RegisterEffect(e1)
	end
	if ct>=10 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			c:RegisterEffect(e1)
	end
end
	function s.spfilter(c,e,tp)
	return c:IsSetCard(0x83e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
	function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
	function s.costfilter(c)
	return c:IsSetCard(0x83e) and c:IsFaceup() and c:IsAbleToDeckAsCost()
end
	function s.crost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.costfilter,tp,LOCATION_REMOVED,0,nil)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_REMOVED,0,1,99,nil)
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
	e:SetLabel(#sg)
end
	function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,nil,0)
end
	function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
	end
end
	function s.cofilt(c)
	return c:IsSetCard(0x83e) and c:IsAbleToRemoveAsCost()
end 
	function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cofilt,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cofilt,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
	function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
	function s.efilter(e,te)
	local c=e:GetHandler()
	if te:GetHandler()==c then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c)
end