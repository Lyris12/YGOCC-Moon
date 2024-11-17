--[[
All Falls To Ruin
Tutto Cade In Rovina
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[For the rest of this Duel, apply the following effects.
	● Once during each End Phase, destroy all monsters controlled by the turn player's opponent.
	● Once during each Standby Phase, the turn player can Special Summon 1 monster from their GY, but its ATK/DEF become 0, also it becomes Rock,
	and if its Type changed this way, its effects are negated.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.PlayerHasFlagEffect(tp,id)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:OPT()
	e1:SetFunctions(s.descon,nil,nil,s.desop)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:OPT()
	e2:SetFunctions(s.spcon,nil,nil,s.spop)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	Duel.RegisterEffect(e3,1-tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(Duel.GetTurnPlayer(),0,LOCATION_MZONE)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(Duel.GetTurnPlayer(),0,LOCATION_MZONE)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,aux.Necro(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2,true)
		local race=tc:GetRace()
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(RACE_ROCK)
		if tc:RegisterEffect(e3,true) and tc:GetRace()&RACE_ROCK>0 and race&RACE_ROCK==0 then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e4,true)
		end
	end
	Duel.SpecialSummonComplete()
end