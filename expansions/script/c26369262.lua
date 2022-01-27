--Psychostizia S.W.A.T.
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT,false,false,1,false,true)
	--boost
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD)
	p2:SetCode(EFFECT_UPDATE_ATTACK)
	p2:SetRange(LOCATION_SZONE)
	p2:SetTargetRange(LOCATION_MZONE,0)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2c2))
	p2:SetValue(200)
	c:RegisterEffect(p2)
	local p3=p2:Clone()
	p3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(p3)
	local p4=p2:Clone()
	p4:SetCode(EFFECT_PIERCE)
	p4:SetValue(1)
	c:RegisterEffect(p4)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.indtg)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e) and s.acttg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function s.negfilter(c)
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		local ct=(Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END) and 2 or 1
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
			tc:RegisterEffect(e1)
		end
	end
end

function s.indfilter(c)
	return c:IsSetCard(0x2c2) and c:IsFaceup()
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.indfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local ct=(Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END) and 2 or 1
		local e1=Effect.CreateEffect(c)
		e1:GLString(5)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:GLString(4)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		tc:RegisterEffect(e2)
		if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp,true) and r&REASON_EFFECT==0 then
			Duel.BreakEffect()
			aux.PandAct(c)(e,tp,eg,ep,ev,re,r,rp)
			local te=c:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=c:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	end
end