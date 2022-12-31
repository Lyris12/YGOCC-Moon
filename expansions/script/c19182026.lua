--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,f,...)
	return c:GetEquipTarget()~=nil and f(...) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local g0=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_SZONE,0,nil,Card.IsSetCard,0xa88)
	local g1=g0:Filter(Card.IsSetCard,nil,0x1a88)
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_SZONE,0,nil,Card.IsCode,id-3,id-1)
	if chk==0 then return #g0>0 and #g1>0 and (#g0-#g1>0 or #g0>1 and #g1>1)
		and g2:GetClassCount(Card.GetCode)>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=g0:Select(tp,1,1,nil)
	g:Merge(g1:Select(tp,1,1,g))
	aux.GCheckAdditional=aux.dncheck
	g:Merge(g2:SelectSubGroup(tp,aux.TRUE,false,2,2))
	aux.GCheckAdditional=nil
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c,e,tp,loc)
	return c:IsSetCard(0xa88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsSetCard,aux.NOT(Card.IsForbidden)),tp,loc,0,1,c,0xa88)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then
			return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,LOCATION_GRAVE)
		else
			e:SetLabel(0)
			return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,LOCATION_SZONE+LOCATION_GRAVE)
		end
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.ctfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsLocation(LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	local gt=#g
	Duel.SendtoGrave(g,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	g=Duel.GetOperatedGroup()
	if ft<=0 or #g~=gt then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,LOCATION_GRAVE)
	if #sg>0 then
		Duel.BreakEffect()
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local tc=sg:GetFirst()
		ft=ft-1
		local ct=g:FilterCount(s.ctfilter,nil,1-tp)
		if ft>ct then ft=ct end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSetCard,aux.NOT(Card.IsForbidden)),tp,LOCATION_GRAVE,0,ft,ft,nil,0xa88)
		for ec in aux.Next(g) do Duel.Equip(tp,ec,tc,true,true) end
		Duel.EquipComplete()
	end
end
