--Aeonstrider Enigma - Zana
--Enigma Marciaeoni - Zana
--Scripted by: XGlitchy30

local s,id,o=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,s.TLcon,{s.TLmaterial,true},{s.TLop,s.TLval})
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:EnableReviveLimit()
	--[[If this card is Special Summoned: You can add to your hand, 1 of your "Aeonstride" Spells/Traps that is banished or in your GY,
	and if you do, you can banish this card and up to 1 card from either field.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--[[At the start of the Battle Phase, while this card is banished: You can Special Summon this card, and if you do, it gains 1000 ATK, then move the Turn Count forwards by 1 Turn. ]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e2:SetRange(LOCATION_REMOVED)
	e2:HOPT()
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_DECK)
		ge1:SetCondition(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsInExtra,nil)
	if #g==0 then return end
	for p=0,1 do
		if g:IsExists(Card.IsControler,1,nil,p) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end

--PROC
function s.TLcon(e,c)
	return Duel.PlayerHasFlagEffect(c:GetControler(),id)
end
function s.TLmaterial(c,e)
	return c:CheckTimeleapMaterialLevel(e:GetHandler()) or (c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsLevelBelow(4))
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c,g)
	local pg=g:Filter(Card.IsType,nil,TYPE_PENDULUM)
	if #pg>0 then
		g:Sub(pg)
		Duel.SendtoExtraP(pg,nil,REASON_MATERIAL|REASON_TIMELEAP)
	end
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	end
end
function s.TLval(c,e,tp)
	if not c:IsMonster(TYPE_PENDULUM) or not c:IsAbleToExtra() then return false end
	return true
end

--FILTERS E1
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsST() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsAbleToHand()
end
function s.fgoal(g,c)
	if not g:IsContains(c) then return false end
	local eg=g:Filter(aux.TRUE,c)
	return #eg<=1 or eg:GetClassCount(Card.GetControler)==2
end
--E1
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_GB,0,1,nil)
	end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GB)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,1,c:GetControler(),c:GetLocation())
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GB,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsAbleToRemove() and c:AskPlayer(tp,STRING_ASK_BANISH) then
				local rg=Duel.Group(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
				rg:AddCard(c)
				Duel.HintMessage(tp,HINTMSG_REMOVE)
				local sg=rg:SelectSubGroup(tp,s.fgoal,false,1,3,c)
				if #sg>0 then
					Duel.ShuffleHand(tp)
					Duel.HintSelection(sg)
					Duel.Banish(sg)
				end
			end
		end
	end
end

--FILTERS E2
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,1000)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return false end
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		c:UpdateATK(1000,true,c)
	end
	if Duel.SpecialSummonComplete()>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
		Duel.BreakEffect()
		Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
	end
end