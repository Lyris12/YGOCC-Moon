--Pigra Sovrintendente dei Fossi
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,2)
	local d1=c:DriveEffect(-2,0,CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0),
		nil,
		s.target,
		s.operation
	)
	local d2=c:DriveEffect(-3,1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg(s.spfilter1),
		s.spop
	)
	--ss
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:HOPT()
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sptg(s.spfilter2))
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--search
	local f=aux.Filter(Card.IsCode,74845897)
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.DueToHavingZeroEnergyCond)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(aux.SearchTarget(f))
	e2:SetOperation(aux.SearchOperation(f))
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDefense(200)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.spfilter1(c,e,tp)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDefense(200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
	return c:IsMonster(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and f(chkc,e,tp) end
				if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectTarget(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
			end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end