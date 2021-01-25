--Naviigator's Strike
function c249001140.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249001140.target)
	e1:SetOperation(c249001140.activate)
	c:RegisterEffect(e1)
end
function c249001140.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x22B)
end
function c249001140.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(c249001140.cfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,ct,c)
	end
	local ct=e:GetLabel()
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
function c249001140.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c249001140.cfilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end