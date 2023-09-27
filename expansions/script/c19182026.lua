--Aircaster's Zero Tolerance
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.hnchecks=aux.CreateChecks(Card.IsSetCard,{ARCHE_AIRCASTER,ARCHE_FLAIRCASTER,ARCHE_DESPAIRCASTER,ARCHE_FAIRCASTER})

function s.cfilter(c)
	return c:IsFaceup() and c:IsSpell(TYPE_EQUIP) and c:IsSetCard(ARCHE_AIRCASTER) and c:IsReleasable()
end
function s.hngoal(g,e,tp)
	local sg=Duel.Group(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	sg:Merge(g)
	return g:IsExists(s.hnfilter,1,nil,e,tp,sg,true) and Duel.IsExistingMatchingCard(s.hnfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,sg,false)
end
function s.hnfilter(c,e,tp,g,check)
	return c:IsSetCard(ARCHE_AIRCASTER) and Duel.GetMZoneCount(tp,g)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not check or c:IsMonsterCard())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g0=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g0>0 and g0:CheckSubGroupEach(s.hnchecks,s.hngoal,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g0:SelectSubGroupEach(tp,s.hnchecks,false,s.hngoal,e,tp)
	Duel.Release(sg,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsSetCard(ARCHE_AIRCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,c,tp)
end
function s.eqfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_AIRCASTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sg=Duel.Group(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		return not sg:IsExists(aux.NOT(Card.IsAbleToGrave),1,nil) and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.hnfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,sg,false))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.ctfilter(c,e,p)
	local re=c:GetReasonEffect()
	return c:GetPreviousControler()==p and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT) and re and re==e and not c:IsReason(REASON_REDIRECT)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=Duel.SendtoGrave(g,REASON_EFFECT)
	g=Duel.GetOperatedGroup()
	if ct==0 or Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #sg>0 then
		Duel.BreakEffect()
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local tc=sg:GetFirst()
		if not tc:IsFaceup() then return end
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local ct=math.min(ft,g:FilterCount(s.ctfilter,nil,e,1-tp))
		if ft<=0 or ct==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local eqg=Duel.SelectMatchingCard(tp,aux.Necro(s.eqfilter),tp,LOCATION_GRAVE,0,ct,ct,nil,tp)
		for ec in aux.Next(eqg) do
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,tc,true,true)
		end
		Duel.EquipComplete()
	end
end