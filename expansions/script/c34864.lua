--Continuazione Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,34862)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		return dc and dc:HasLevel() and dc:GetEnergy()<dc:GetLevel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and dc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false)
	end
	Duel.SetTargetCard(dc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dc,1,dc:GetControler(),dc:GetLocation())
end
function s.enfilter(c,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanEngage(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(tc,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,34862),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.enfilter,tp,LOCATION_HAND,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.enfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
		if #g>0 then
			Duel.BreakEffect()
			g:GetFirst():Engage(e,tp)
		end
	end
end