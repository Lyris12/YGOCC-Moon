--Black Ice
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.a_tg)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
end
function s.a_sfil2(c,e,tp,lv)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.a_cfil(c,tp)
	return c:GetLevel()>0 and c:IsAbleToGraveAsCost() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and (c:IsControler(tp) or c:GetCounter(COUNTER_ICE)>0)
end
function s.gcheck(g,e,tp)
	if Duel.GetMZoneCount(tp,g)<=0 then return false end
	local sum=g:GetSum(Card.GetLevel)
	return Duel.IsExistingMatchingCard(s.a_sfil2,tp,LOCATION_DECK,0,1,g,e,tp,sum)
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.a_cfil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then
		return e:IsCostChecked() and cg:CheckSubGroup(s.gcheck,1,#cg,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=cg:SelectSubGroup(tp,s.gcheck,false,1,#cg,e,tp)
	Duel.SetTargetParam(sg:GetSum(Card.GetLevel))
	Duel.SendtoGrave(sg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end

function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		Duel.Damage(tp,2000,REASON_EFFECT)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.a_sfil2,tp,LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetTargetParam())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Damage(tp,2000,REASON_EFFECT)
	end
end