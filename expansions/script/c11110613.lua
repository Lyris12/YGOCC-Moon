--Saji'ita, Lifeweaver's Warmth
--Saji'ita, Calore della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[If this card is Normal Summoned, or Special Summoned by the effect of a "Lifeweaver" card:
	You can Set 1 "Lifeweaver" Spell directly from your Deck, but you cannot Special Summon monsters from your Extra Deck for the rest of this turn, except Time Leap Monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e1x=e1:SpecialSummonEventClone(c,true)
	e1x:SetCondition(s.setconsp)
	c:RegisterEffect(e1x)
	--[[If this card is banished: You can activate this effect; Special Summon 1 of your banished "Lifeweaver" monsters during your opponent's next Standby Phase.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetOperation(s.delayop)
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

--FILTERS E1
function s.setfilter(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsSSetable()
end
--E1
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_TIMELEAP) and c:IsLocation(LOCATION_EXTRA)
end
--E1X
function s.setconsp(e,tp,eg,ep,ev,re,r,rp)
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

--E2
function s.delayop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local rct = Duel.IsStandbyPhase(1-tp) and 2 or 1
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(3)
	e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
	e1:SetCheatCode(CHEATCODE_SET_CHAIN_ID,false,cid)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetLabel(rct,Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_TURN_OPPO,rct)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return Duel.GetTurnPlayer()==1-tp and (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
end