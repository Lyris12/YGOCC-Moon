--Phantomb Raider, (Leader)
local ref,id=GetID()
function ref.initial_effect(c)
	--ritual level
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_RITUAL_LEVEL)
	e0:SetValue(ref.rlevel)
	c:RegisterEffect(e0)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--On-Sacrifice
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+1000)
	--e4:SetCondition(ref.setcon)
	e4:SetTarget(ref.settg)
	e4:SetOperation(ref.setop)
	c:RegisterEffect(e4)
end

--Ritual Level
function ref.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0x732) then
		return lv*65536+7
	else return lv end
end

--Search
function ref.thfilter(c)
	return c:IsSetCard(0x732) and c:IsAbleToHand() and not c:IsCode(id) --or bit.band(c:GetType(),0x81)==0x81)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end

--On-Sacrifice
function ref.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function ref.setfilter(c)
	return c:IsSetCard(0x732) and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(ref.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(ref.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(ref.setfilter),tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		aux.PandSSet(tc,REASON_EFFECT,aux.GetOriginalPandemoniumType(tc))(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
