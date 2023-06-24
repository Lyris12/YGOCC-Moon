--Felsis, Lifeweaver's Confidence
--Felsis, Confidenza della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,3,s.TLcon,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_LIFEWEAVER))
	c:EnableReviveLimit()
	--[[If this card is Time Leap Summoned, or Special Summoned by the effect of a "Lifeweaver" card: You can activate this effect;
	this turn, each time a monster(s) is Summoned or a monster effect is activated, immediately gain 100 LP, also return this card to your Extra Deck during the next Standby Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.prcon)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can banish 1 other "Lifeweaver" monster you control; Special Summon 1 Future 4 "Lifeweaver" Time Leap Monster from your Extra Deck,
	ignoring the Time Leap Limit. (This is treated as a Time Leap Summon.) ]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not aux.LifeweaverTriggeringSetcodeCheck then
		aux.LifeweaverTriggeringSetcodeCheck=true
		aux.LifeweaverTriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		if rc:IsSetCard(ARCHE_LIFEWEAVER) then
			aux.LifeweaverTriggeringSetcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(ARCHE_LIFEWEAVER) then
			aux.LifeweaverTriggeringSetcode[cid]=true
			return
		end
	end
	aux.LifeweaverTriggeringSetcode[cid]=false
end

function s.excfilter(c)
	return c:IsFacedown() or (not c:IsRace(RACE_PSYCHIC) and not c:IsType(TYPE_TIMELEAP))
end
function s.TLcon(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and not g:IsExists(s.excfilter,1,nil)
end

--E1
function s.prcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP) then return true end
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return aux.LifeweaverTriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return aux.LifeweaverTriggeringSetcode[cid]==true
		
	else
		return rc:IsSetCard(ARCHE_LIFEWEAVER)
	end
end
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.lpcon_nonactivated)
	e1:SetOperation(s.lpop_nonactivated)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:SpecialSummonEventClone(c,true)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:FlipSummonEventClone(c,true)
	Duel.RegisterEffect(e3,tp)
	--
	local e4=e1:Clone()
	e4:SetCondition(s.lpcon_activated)
	e4:SetOperation(s.reglpop)
	Duel.RegisterEffect(e4,tp)
	local e5=e4:SpecialSummonEventClone(c,true)
	Duel.RegisterEffect(e5,tp)
	local e6=e4:FlipSummonEventClone(c,true)
	Duel.RegisterEffect(e6,tp)
	--
	local e7=e1:Clone()
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetCondition(s.lpcon_solved)
	e7:SetOperation(s.lpop_activated)
	Duel.RegisterEffect(e7,tp)
	--
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAINING)
	e10:SetOperation(s.regchop)
	e10:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e10,tp)
	local e11=Effect.CreateEffect(c)
	e11:Desc(2)
	e11:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e11:SetCode(EVENT_CHAIN_SOLVED)
	e11:SetCondition(s.lpcon_chain)
	e11:SetOperation(s.lpop_nonactivated)
	e11:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e11,tp)
	--
	Duel.RegisterHint(tp,id,PHASE_END,1,id,3)
	if c:IsRelateToChain() then
		local fid=c:GetFieldID()
		local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
		local rct = Duel.IsStandbyPhase() and 2 or 1
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY,EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT,rct,fid,aux.Stringid(id,4))
		local e1=Effect.CreateEffect(c)
		e1:Desc(5)
		e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
		e1:SetCheatCode(CHEATCODE_SET_CHAIN_ID,false,cid)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetCondition(s.tecon)
		e1:SetOperation(s.teop)
		e1:SetLabel(rct,Duel.GetTurnCount(),fid)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY,rct)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.lpcon_nonactivated(e,tp,eg,ep,ev,re,r,rp)
	return not re or not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.lpop_nonactivated(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(tp,100,REASON_EFFECT)
end
function s.lpcon_activated(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.reglpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.lpcon_solved(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.lpop_activated(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	Duel.Recover(tp,n*100,REASON_EFFECT)
end
function s.regchop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) then
		Duel.RegisterFlagEffect(tp,id+100,RESET_CHAIN,0,1)
	end
end
function s.lpcon_chain(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)>0
end
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn,fid=e:GetLabel()
	local c=e:GetOwner()
	if not c or not c:HasFlagEffectLabel(id,fid) then
		e:Reset()
		return false
	end
	return sp_label==1 or turn~=Duel.GetTurnCount()
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetOwner()
	if c:IsAbleToExtra() then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--FILTERS E2
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c)
end
function s.spfilter(c,e,tp,rc)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsFuture(4)
		and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false)
end
--E2
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c,e,tp)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	if #g>0 then
		Duel.Banish(g,nil,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_TIMELEAP,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end