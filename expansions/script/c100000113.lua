--Aeonstrider Divergence
--Divergenza Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:Activation(true)
	--[[Once per turn: You can move the Turn Count forwards or backwards by 1 turn, then gain 500 LP.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[Once per turn, if the Turn Count is moved by an "Aeonstride" card effect (except during the Damage Step):
	You can Special Summon 1 of your "Aeonstride" Monster Cards that is banished or in your Pendulum Zone, and if you do,
	it cannot be targeted by your opponent's card effects, until the end of the turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[If this card is banished: You can banish 1 "Aeonstride" card from your hand, GY, or face-up Extra Deck, except "Aeonstrider Divergence"; add this card to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetFunctions(nil,aux.BanishCost(s.cfilter,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA),s.thtg,s.thop)
	c:RegisterEffect(e3)
	if not s.TriggeringSetcodeCheck then
		s.TriggeringSetcodeCheck=true
		s.TriggeringSetcode={}
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
		if rc:IsSetCard(ARCHE_AEONSTRIDE) then
			s.TriggeringSetcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(ARCHE_AEONSTRIDE) then
			s.TriggeringSetcode[cid]=true
			return
		end
	end
	s.TriggeringSetcode[cid]=false
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for i=-1,1,2 do
			if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local nums={}
	for i=-1,1,2 do
		if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) then
			table.insert(nums,i)
		end
	end
	if #nums==0 then return end
	Duel.HintMessage(tp,STRING_INPUT_MOVE_TURN_COUNT)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	if Duel.MoveTurnCountCustom(ct,e,tp,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end

--FILTERS E2
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re or r&REASON_EFFECT==0 then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	else
		return rc:IsSetCard(ARCHE_AEONSTRIDE)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_PZONE|LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_PZONE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetDescription(STRING_CANNOT_BE_TARGETED_BY_OPPONENT_EFFECT)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e0:SetValue(aux.tgoval)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		g:GetFirst():RegisterEffect(e0)
	end
end

--FE3
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_AEONSTRIDE) and not c:IsCode(id)
end
--E3
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end