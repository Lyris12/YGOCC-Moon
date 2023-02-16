--Abyss Actor - Queen of Style
--scripted by Rawstone

local s,id=GetID()
function s.initial_effect(c)
--pendulum summon
	aux.EnablePendulumAttribute(c)
	--no responding
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.chainop)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.cond)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.cond)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--change effect
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.chcon4)
	e4:SetOperation(s.chop2)
	c:RegisterEffect(e4)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(0x20ec) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp 
end

function s.indfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsLevelAbove(7) and c:IsType(TYPE_PENDULUM)
end
function s.cond(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.confilter1(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.chcon4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter1,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and (e:GetActiveType()==TYPE_SPELL or e:GetActiveType()==TYPE_TRAP) then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end