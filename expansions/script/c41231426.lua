--created by Jake, coded by Lyris
--Disgraceful Battle at Dawn
if not global_override_reason_effect_check then
	global_override_reason_effect_check = true
end
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.hcon)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsRace(RACE_ALL-RACE_WARRIOR) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:GetAttack()>atk
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.SelectMatchingCard(tps.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetAttack())
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	if not (Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(id,0))) then return end
	if not s.scapetoken then
		local token=Duel.CreateToken(tp,UNIVERSAL_GLITCHY_TOKEN)
		token:SetStatus(STATUS_NO_LEVEL,true)
		s.scapetoken=token
	end
	s.scapetoken:Recreate(id,0,0x613,(s.scapetoken:GetType()&~TYPE_NORMAL)|e:GetHandler():GetType(),0,0,0,0)
	local fake_re=e:Clone()
	s.scapetoken:RegisterEffect(fake_re,true)
	fake_re:SetCheatCode(GECC_OVERRIDE_ACTIVE_TYPE)
	e:SetCheatCode(GECC_OVERRIDE_REASON_EFFECT,true,fake_re)
	Duel.RaiseSingleEvent(tc,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
	Duel.RaiseEvent(tc,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk=0 then return e:IsCostChecked() end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e:GetLabel()),REASON_EFFECT)
end
function s.hcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer,LOCATION_MZONE,0)<1 end
end
