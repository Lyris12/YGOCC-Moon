--Operatore di Tellurio
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,15)
	local d1=c:DriveEffect(0,0,nil,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F,nil,EVENT_ENGAGE,
		nil,
		nil,
		nil,
		s.operation
	)
	local d2=c:DriveEffect(-5,1,CATEGORY_DRAW,EFFECT_TYPE_IGNITION,EFFECT_FLAG_PLAYER_TARGET,nil,
		nil,
		s.drawcost,
		aux.DrawTarget(),
		aux.DrawOperation()
	)
	local d3=c:OverDriveEffect(2,CATEGORY_DESTROY,EFFECT_TYPE_QUICK_O,nil,EVENT_FREE_CHAIN,
		aux.CompareLocationGroupCond(1,nil,LOCATION_ONFIELD),
		nil,
		aux.DestroyTarget({SUBJECT_ALL,aux.TRUE},LOCATION_ONFIELD,LOCATION_ONFIELD),
		aux.DestroyOperation({SUBJECT_ALL,aux.TRUE},LOCATION_ONFIELD,LOCATION_ONFIELD)
	)
	--shuffle
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.DriveSummonedCond)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--drive summon
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:HOPT()
	e3:SetCondition(aux.ByCardEffectCond(1))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsEngaged() then
		local ct=Duel.GetFieldGroupCount(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if ct>0 then
			c:UpdateEnergy(-ct,tp,REASON_EFFECT,true)
		end
	end
end

function s.dcfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsDiscardable()
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local exc
		if c:IsEngaged() and c:CheckZeroEnergySelfDestroy(-5) then
			exc=c
		end
		return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,exc)
	end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST+REASON_DISCARD)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and en and en:IsMonster() and en:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false) end
	Duel.SetCardOperationInfo(en,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local en=Duel.GetEngagedCard(tp)
	if en and en:IsMonster() and Duel.SpecialSummon(en,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)>0 then
		en:CompleteProcedure()
	end
end