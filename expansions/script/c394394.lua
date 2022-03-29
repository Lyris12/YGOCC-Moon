--Dorein Notte Rischiarata dalla Luna
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--count damage
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-ep then
		s[rp]=s[rp]+ev
	end
end
function s.damchk(val)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then tp=e:GetHandlerPlayer() end
				return s[tp]>=val
			end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLP(1-tp)>=3000 and s.damchk(1000)(e,tp)
	local b2=Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and s.damchk(2000)(e,tp)
	local b3=Duel.IsPlayerCanDraw(tp,1) and s.damchk(3000)(e,tp)
	if chk==0 then return (b1 or b2 or b3) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLP(1-tp)>=3000 and s.damchk(1000)(e,tp)
	local b2=Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and s.damchk(2000)(e,tp)
	local b3=Duel.IsPlayerCanDraw(tp,1) and s.damchk(3000)(e,tp)
	local flag=0
	if b1 and ((not b2 and not b3) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		flag=1
		b2=Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and s.damchk(2000)(e,tp)
		b3=Duel.IsPlayerCanDraw(tp,1) and s.damchk(3000)(e,tp)
	end
	if b2 and ((flag==0 and not b3) or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd04))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		flag=1
	end
	if b3 and (flag==0 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end