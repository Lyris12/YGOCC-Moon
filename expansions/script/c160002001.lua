--Legendary Shark
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
 aux.AddEvoluteProc(c,nil,5,cid.filter1,cid.filter2,2)  

--spsummon proc
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id)
	e0:SetCondition(cid.hspcon)
	e0:SetOperation(cid.hspop)
	e0:SetValue(SUMMON_TYPE_SPECIAL+388)
	c:RegisterEffect(e0)
  --immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.econ)
	e1:SetValue(cid.efilter)
	c:RegisterEffect(e1)
  --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(cid.hdcost)
	e2:SetTarget(cid.destg)
	e2:SetOperation(cid.desop)
	c:RegisterEffect(e2)
  --tohand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+20)
	e4:SetCondition(cid.thcon)
	e4:SetTarget(cid.thtg)
	e4:SetOperation(cid.thop)
	c:RegisterEffect(e4)
end
function cid.econ(e)
	return Duel.IsEnvironment(22702055)
end

function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)
end

function cid.spfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel() => 5  and c:IsAttribute(ATTRIBUTE_WATER) 
end
function cid.check()
	return Duel.IsEnvironment(22702055)
end
function cid.hspcon(e,c)
  if c==nil then return true end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_MZONE,0,1,nil)  and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and cid.check()
end
function cid.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end
function cid.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function cid.thfilter2(c)
	return aux.IsCodeListed(c,22702055) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.thfilter2,tp,LOCATION_DECK,0,1,nil) end
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
Duel.SSet(tp,tc)

end

function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetPreviousControler()==tp
end
function cid.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)  and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
