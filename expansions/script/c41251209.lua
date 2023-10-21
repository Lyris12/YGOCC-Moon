--Daylilly Monarch Rose
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(id)
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--plant world
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetCondition(s.fieldcon)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
	local e2g=e2:Clone()
	e2g:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2g:SetCondition(s.gravecon)
	c:RegisterEffect(e2g)
	--negate
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,id+100)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:Desc(3)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.spcon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.cfilter1(c,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and (c:IsFaceup() or c:IsControler(tp))
		and (Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) or (c:IsOwner(tp) and c:IsAbleToGraveAsCost()))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.cfilter1,nil,tp)
	if chk==0 then return #g1>0 end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local sg=g1:Select(tp,1,1,nil)
	local exg=sg:Filter(Auxiliary.ExtraReleaseFilter,nil,tp)
	for ec in Auxiliary.Next(exg) do
		local te=ec:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
		if te and (not g2:IsContains(ec) or Duel.SelectYesNo(tp,STRING_ASK_EXTRA_RELEASE_NONSUM)) then
			Duel.Hint(HINT_CARD,tp,te:GetHandler():GetOriginalCode())
			te:UseCountLimit(tp)
		end
	end
	Duel.Release(sg,REASON_COST)
end
function s.thfilter(c)
	return c:IsMonster(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

function s.fieldcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLACK_GARDEN),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.gravecon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLACK_GARDEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end

function s.cfilter(c,e,tp,eg)
	return not eg:IsContains(e:GetHandler()) and c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=eg:Filter(aux.NegateMonsterFilter,nil)
	if chk==0 then return #sg>0 end
	local g
	if #sg>1 then
		Duel.HintMessage(tp,aux.Stringid(id,3))
		g=sg:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#sg,id+100,sg)
		Duel.HintSelection(g)
	else
		g=sg:Clone()
	end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards()
	for tc in aux.Next(g) do
		local _,_,res=Duel.Negate(tc,e)
		if res then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_REMOVE_TYPE)
			e1:SetValue(TYPE_EFFECT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE)
end
function s.spcfilter1(c,tp,ec)
	if not (not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and (c:IsFaceup() or c:IsControler(tp))) then return false end
	if ec:GetLocation()&LOCATION_EXTRA>0 then
		return Duel.GetLocationCountFromEx(tp,tp,c,ec,0x1f)>0
	else
		return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,0x1f)>0
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.spcfilter1,nil,tp,c)
	if chk==0 then
		return #g1>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	end
	
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local sg=g1:Select(tp,1,1,nil)
	local exg=sg:Filter(Auxiliary.ExtraReleaseFilter,nil,tp)
	for ec in Auxiliary.Next(exg) do
		local te=ec:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
		if te and (not g2:IsContains(ec) or Duel.SelectYesNo(tp,STRING_ASK_EXTRA_RELEASE_NONSUM)) then
			Duel.Hint(HINT_CARD,tp,te:GetHandler():GetOriginalCode())
			te:UseCountLimit(tp)
		end
	end
	Duel.Release(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,0x1f)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,0x1f)
	end
end