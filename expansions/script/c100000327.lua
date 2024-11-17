--[[
Monolit by the Moon
Monolluminato dalla Luna
Card Author: MoonRite
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--[[If a card or effect is activated (except during the Damage Step): You can place 1 "Monolit by the Sun" from your Deck in your Pendulum Zone, and if you do, during the End Phase of this turn, apply this effect.
	● Immediately after this effect resolves, Pendulum Summon a monster(s), then destroy all cards in your Pendulum Zone.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT(EFFECT_COUNT_CODE_DUEL)
	e1:SetFunctions(nil,nil,s.pstg,s.psop)
	c:RegisterEffect(e1)
	--[[If this card is destroyed by battle or card effect: You can activate this effect; add 1 Pendulum Monster from your Deck to your hand during the End Phase of this turn,
	except "Monolit by the Moon".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:HOPT()
	e2:SetFunctions(aux.ByBattleOrCardEffectCond(),nil,s.regtg,s.regop)
	c:RegisterEffect(e2)
end
--E1
function s.pcfilter(c,tp)
	return c:IsCode(id+1) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_PZONE)
end
function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckPendulumZones(tp) and Duel.IsExists(false,s.pcfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_PZONE)
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and tc:IsControler(tp) and tc:IsLocation(LOCATION_PZONE) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,1)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:OPT()
		e1:SetCondition(s.pendsumcon)
		e1:SetOperation(s.pendsumop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.pendsumcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.MonsterFilter(Card.IsFaceupEx),tp,LOCATION_HAND|LOCATION_EXTRA,0,nil)
	if #g==0 then return false end
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then
		lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if lpz==nil then
			return false
		end
	end
	local res=aux.PendCondition(e,lpz,g)
	return res
end
function s.pendsumop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.MonsterFilter(Card.IsFaceupEx),tp,LOCATION_HAND|LOCATION_EXTRA,0,nil)
	if #g==0 then return end
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then
		lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if lpz==nil then
			return
		end
	end
	Duel.Hint(HINT_CARD,tp,id)
	local sg=Group.CreateGroup()
	aux.PendOperation(e,tp,eg,ep,ev,re,r,rp,lpz,sg,g)
	if Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)>0 then
		local dg=Duel.Group(aux.TRUE,tp,LOCATION_PZONE,0,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

--E2
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,3)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:OPT()
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end