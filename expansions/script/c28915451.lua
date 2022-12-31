--Phantomb Raider, 
local ref,id=GetID()
function ref.initial_effect(c)
	--ritual level
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_RITUAL_LEVEL)
	e0:SetValue(ref.rlevel)
	c:RegisterEffect(e0)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(0,id))
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.settg)
	e1:SetOperation(ref.setop)
	c:RegisterEffect(e1)
	--On-Sacrifice
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1000)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
end

--Ritual Level
function ref.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0x732) then
		return lv*65536+7
	else return lv end
end

--Set
function ref.setcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsReleasable() --c:IsSetCard(0x732) and
end
function ref.setfilter(c)
	return c:IsSetCard(0x732) and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(ref.setcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and aux.PandSSetCon(ref.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(ref.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,ref.setcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(ref.setfilter),tp,LOCATION_DECK,0,1,1,nil)
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
end

--On-Sacrifice
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function ref.thfilter(c)
	return c:IsSetCard(0x732) and c:IsAbleToHand() and not c:IsCode(id)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(ref.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,ref.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
