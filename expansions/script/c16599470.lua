--Posterus dell'Organizzazione Angeli, Cras
--Script by XGlitchy30
function c16599470.initial_effect(c)
	c:SetSPSummonOnce(16599470)
	--link summon
	aux.AddLinkProcedure(c,c16599470.matfilter,1,1)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(c16599470.splimit)
	c:RegisterEffect(e0)
	--target protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c16599470.efilter)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16599470,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c16599470.sccon)
	e2:SetCost(c16599470.sccost)
	e2:SetTarget(c16599470.sctg)
	e2:SetOperation(c16599470.scop)
	c:RegisterEffect(e2)
	--synchro summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16599470,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,16599470)
	e3:SetCost(c16599470.spcost)
	e3:SetTarget(c16599470.sptg)
	e3:SetOperation(c16599470.spop)
	c:RegisterEffect(e3)
end
--filters
function c16599470.lcheck(g,lc)
	return g:IsExists(c16599470.matfilter,1,nil)
end
function c16599470.matfilter(c)
	return c:GetAttack()==0
end
function c16599470.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetLevel()>0
end
function c16599470.mfilter(c,link)
	return c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x10000008)==0x10000008 and c:GetReasonCard()==link
		and c:IsAbleToRemoveAsCost()
end
function c16599470.scfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1559) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function c16599470.cfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c16599470.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,c:GetOriginalLevel())
end
function c16599470.synfilter(c,tp,tc,lv)
	local check=false
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	mg:AddCard(tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	tc:RegisterEffect(e1)
	if c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY) and c:IsSynchroSummonable(nil,mg) then
		check=true
	end
	e1:Reset()
	return check
end
function c16599470.synfilter2(c,tp,tc)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	mg:AddCard(tc)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY) and c:IsSynchroSummonable(nil,mg)
end
function c16599470.spfilter(c,e,tp,lv)
	return c:IsFaceup() and c:IsSetCard(0x1559) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()>0 and c:GetOriginalLevel()~=lv
		and Duel.IsExistingMatchingCard(c16599470.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp,c,lv)
end
--spsummon condition
function c16599470.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
--target protection
function c16599470.efilter(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--search
function c16599470.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c16599470.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local matc=mat:GetCount()
	if chk==0 then return matc>0 and mat:FilterCount(c16599470.mfilter,nil,c)==matc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=mat:Select(tp,matc,matc,nil)
	if g:GetCount()==matc then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599470.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599470.scfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function c16599470.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16599470.scfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetTarget(c16599470.sumlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e2,tp)
		local e2x=e1:Clone()
		e2x:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		Duel.RegisterEffect(e2x,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		Duel.RegisterEffect(e3,tp)
	end
end
function c16599470.sumcon(e)
	return e:GetHandler():IsRelateToCard(e:GetLabelObject())
end
function c16599470.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
--synchro summon
function c16599470.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function c16599470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c16599470.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanSpecialSummonCount(tp,2) and c:IsAbleToRemoveAsCost() 
			and Duel.IsExistingMatchingCard(c16599470.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
			and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:GetSequence()<5)
	end
	local g=Duel.GetMatchingGroup(c16599470.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	e:SetLabel(tc:GetLevel())
	Duel.Remove(Group.FromCards(c,tc),POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c16599470.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c16599470.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
			Duel.SpecialSummonComplete()
			local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
			local sg=Duel.GetMatchingGroup(c16599470.synfilter2,tp,LOCATION_EXTRA,0,nil,tp,g:GetFirst())
			if #sg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local rg=sg:Select(tp,1,1,nil)
				Duel.SynchroSummon(tp,rg:GetFirst(),nil,mg)
			end
		end
	end
end