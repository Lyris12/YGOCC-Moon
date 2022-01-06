--Zextratum, Il Drago Abissomonium
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	c:EnableReviveLimit()
	--extra pandemonium zone
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_SINGLE)
	p0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	p0:SetCode(EFFECT_ALLOW_EXTRA_PANDEMONIUM_ZONE)
	p0:SetRange(0xff)
	c:RegisterEffect(p0)
	--nuke
	local p1=Effect.CreateEffect(c)
	p1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(cid.actcon)
	p1:SetTarget(cid.acttg)
	p1:SetOperation(cid.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_EFFECT+TYPE_RITUAL,false,cid.actcost,1,false,true)
	--immunity
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD)
	p2:SetCode(EFFECT_IMMUNE_EFFECT)
	p2:SetRange(LOCATION_SZONE)
	p2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_PANDEMONIUM) and c:IsStatus(STATUS_SPSUMMON_TURN) end)
	p2:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(p2)
	--MONSTER EFFECTS
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cid.atkval)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cid.atktg)
	e2:SetValue(cid.atkval2)
	c:RegisterEffect(e2)
	--leave replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(cid.reptg)
	e3:SetValue(cid.repval)
	e3:SetOperation(cid.repop)
	c:RegisterEffect(e3)
end
function cid.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
--NUKE
function cid.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.prevfilter(c,tp)
	return c:GetPreviousControler()==tp
end
-----------
function cid.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e)
end
function cid.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	local ct=math.min(2,#g)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(cid.chainlm)
	end
end
function cid.chainlm(e,rp,tp)
	return tp==rp
end
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if #g>0 then
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		local ct=Duel.GetOperatedGroup():FilterCount(cid.prevfilter,nil,tp)
		if ct>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
--ATK UP
function cid.atkfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and (c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) or (c:IsLocation(LOCATION_SZONE) and c:GetFlagEffect(726)>0))
end
---------
function cid.atkval(e,c)
	local g=Duel.GetMatchingGroup(cid.atkfilter,e:GetHandlerPlayer(),LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_SZONE,0,nil)
	local atk=g:GetSum(Card.GetBaseAttack)
	return atk
end
--ATK DOWN
function cid.atktg(e,c)
	return c~=e:GetHandler()
end
function cid.atkval2(e,c)
	local g=Duel.GetMatchingGroup(cid.atkfilter,e:GetHandlerPlayer(),LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_SZONE,0,nil)
	local atk=g:GetSum(Card.GetBaseAttack)
	return -atk
end
--LEAVE REPLACE
--filters
function cid.repfilter(c,e)
	return c:IsLocation(LOCATION_ONFIELD) and not c:IsReason(REASON_REPLACE)
		and bit.band(c:GetDestination(),LOCATION_MZONE)==0 and bit.band(c:GetDestination(),LOCATION_SZONE)==0
		and bit.band(c:GetDestination(),LOCATION_FZONE)==0 and bit.band(c:GetDestination(),LOCATION_PZONE)==0
end
function cid.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
---------
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return r&REASON_EFFECT~=0 and re and rp~=tp and cid.repfilter(e:GetHandler(),e)
		and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_DECK,0,2,nil) 
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		return true
	end
	return false
end
function cid.repval(e,c)
	return cid.repfilter(c,e)
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_DECK,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end