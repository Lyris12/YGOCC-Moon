--Deltaingranaggi Alfa
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xfa6),3,true)
	aux.AddContactFusionProcedure(c,s.matfilter,LOCATION_MZONE,LOCATION_MZONE,aux.tdcfop(c))
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--protection
	c:EffectProtection()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:HOPT()
	e1:SetTarget(aux.SearchTarget(s.thfilter))
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--negate
	c:CreateNegateEffect(true,1,nil,1,nil,true,nil,aux.TributeSelfCost,nil,nil)
	--spsummon back
	c:TributedTrigger(true,nil,nil,EFFECT_FLAG_CANNOT_DISABLE,nil,s.regcon,nil,nil,s.regop,0)
	c:PhaseTrigger(false,PHASE_END,2,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_GRAVE,true,s.spcon,nil,aux.SSSelfTarget(),aux.SSSelfOperation())
	--spsummon
	c:DestroyedTrigger(true,2,CATEGORY_SPECIAL_SUMMON,nil,true,nil,nil,aux.SSTarget(s.spfilter,LOCATION_HAND+LOCATION_GRAVE),aux.SSOperation(s.spfilter,LOCATION_HAND+LOCATION_GRAVE))
end
function s.matfilter(c,fc)
	local tp=fc:GetControler()
	return c:IsAbleToDeckOrExtraAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(0xfa6)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsCode(e:GetLabel())
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re and re:GetOwner()==c and re:IsActivated()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.spcon(e,tp)
	return e:GetHandler():HasFlagEffect(id)
end

function s.spfilter(c)
	return c:IsSetCard(0xfa6) and not c:IsCode(id)
end