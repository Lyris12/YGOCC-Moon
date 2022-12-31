--Striga di Mercurio
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,8)
	local d1=c:DriveEffect(-2,0,CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,nil,s.thcost,s.thtg(s.filter1),s.thop(s.filter1))
	local d2=c:OverDriveEffect(1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,nil,nil,s.sptg,s.spop)
	--SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.thtg(s.filter2))
	e1:SetOperation(s.thop(s.filter2))
	c:RegisterEffect(e1)
	--decrease energy
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetCondition(s.encon)
	e2:SetCost(aux.DiscardSelfCost)
	e2:SetTarget(s.entg)
	e2:SetOperation(s.enop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsDiscardable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,aux.ExceptThis(c))
end
function s.filter1(c)
	return c:IsSetCard(0x660) and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsEnergyBelow(7) and c:IsAbleToHand()
end
function s.thtg(f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK,0,1,nil) end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
			end
end
function s.thop(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
				if #g>0 then
					Duel.Search(g,tp)
				end
			end
end

function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsEnergyBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_DRIVE) and c:IsLocation(LOCATION_DECK)
end

function s.encon(e,tp)
	return not e:GetHandler():IsEngaged() and Duel.GetTurnPlayer()==1-tp
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local en=Duel.GetEngagedCard()
		if en==nil then return false end
		for i=1,5 do
			if en:IsCanUpdateEnergy(-i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard()
	if en==nil then return end
	local nums={}
	for i=1,5 do
		if en:IsCanUpdateEnergy(-i,tp,REASON_EFFECT) then
			table.insert(nums,i)
		end
	end
	if #nums==0 then return end
	local n=Duel.AnnounceNumber(tp,table.unpack(nums))
	en:UpdateEnergy(-n,tp,REASON_EFFECT)
end