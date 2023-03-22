--Anomalia delle Profondità
--Script by: XGlitchy30 & Lyris

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetTarget(aux.SearchTarget(aux.FilterBoolFunction(Card.IsCode,32703716,21507589,87313164,94626050)))
	e2:SetOperation(aux.SearchOperation(aux.FilterBoolFunction(Card.IsCode,32703716,21507589,87313164,94626050)))
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then return en and en:IsMonster() and en:IsCanUpdateEnergy(-5,tp,REASON_COST) end
	en:UpdateEnergy(-5,tp,REASON_COST,true,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP,0xff,LOCATION_DECKSHF)
	end
end
