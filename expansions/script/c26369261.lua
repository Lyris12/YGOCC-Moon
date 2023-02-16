--Psychostizia Spec-Ops
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
	--return to hand
	local p2=Effect.CreateEffect(c)
	p2:GLString(1)
	p2:SetCategory(CATEGORY_TOHAND)
	p2:SetType(EFFECT_TYPE_QUICK_O)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p2:SetCode(EVENT_FREE_CHAIN)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCountLimit(1,id)
	p2:SetCondition(s.sccon)
	p2:SetCost(s.sccost)
	p2:SetTarget(s.sctg)
	p2:SetOperation(s.scop)
	c:RegisterEffect(p2)
	--direct atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	--set
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+200)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
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

function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and aux.PandActCheck(e)
end
function s.costfilter(c,e,tp)
	return c:IsDestructable(e,REASON_COST,tp) and c:IsSetCard(0x2c2) and c:IsFaceup()
end
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_COST)
	end
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end

function s.setfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsForbidden() then return false end
	if not c:IsSetCard(0x2c2) or not c:IsType(TYPE_PANDEMONIUM+TYPE_TRAP) then return false end
	if c:IsType(TYPE_TRAP) then
		return c:IsSSetable(false)
	elseif c:IsType(TYPE_PANDEMONIUM) then
		return aux.PandSSetCon(c,tp,true)(nil,e,tp,eg,ep,ev,re,r,rp) 
	end
	return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if #g<=0 then return end
	local tc=g:GetFirst()
	if tc then
		if tc:IsType(TYPE_PANDEMONIUM) then
			aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		else
			Duel.SSet(tp,tc)
		end
		if tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		end
	end
end

function s.cfilter(c,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,tp)
end
function s.actfilter(c,tp)
	return c:IsSetCard(0x2c2) and (c:IsType(TYPE_FIELD) or c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE>0)) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==1 or Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
		e:SetLabel(0)
		return res
	end
	if not Duel.CheckPhaseActivity() then e:SetLabel(100) else e:SetLabel(0) end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(15248873,0))
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.ResetFlagEffect(tp,15248873)
	if tc then
		local loc=LOCATION_SZONE
		if tc:IsType(TYPE_FIELD) then
			loc=LOCATION_FZONE
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
		end
		if Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) then
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if tc:IsType(TYPE_FIELD) then
				Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			end
			local c=e:GetHandler()
			if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp,true) and r&REASON_EFFECT==0
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
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
end