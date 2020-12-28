--革新者的追猎 莫洛
function c33700323.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33700323,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33700323.thtg)
	e1:SetOperation(c33700323.thop)
	c:RegisterEffect(e1)	
end
function c33700323.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:IsSetCard(0x6449)
end
function c33700323.tffilter(c,tp)
	return c:IsFaceup() and not c:IsCode(33700323) and not c:IsForbidden() and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
end
function c33700323.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() and (Duel.IsExistingMatchingCard(c33700323.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) or Duel.IsExistingMatchingCard(c33700323.tffilter,tp,LOCATION_EXTRA,0,1,nil,tp)) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c33700323.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33700323.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(c33700323.tffilter,tp,LOCATION_EXTRA,0,nil,tp)
	local op
	if #g1>0 and #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(33700323,1),aux.Stringid(33700323,2))
	elseif #g1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(33700323,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(33700323,2))+1
	end
	if op==nil then return end
	local g=(op==0) and g1 or g2
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_EXTRA) then
	   Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	else
	   Duel.SendtoHand(tc,nil,REASON_EFFECT)
	   Duel.ConfirmCards(1-tp,tc)
	end
end