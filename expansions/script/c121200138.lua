--Winter Solstice
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30


local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	c:RegisterEffect(e1)
	--retcounter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.a_tg)
	e2:SetOperation(s.a_op)
	c:RegisterEffect(e2)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c,LOCATION_FZONE)
end
function s.checkct(g,val)
	local ct=0
	for c in aux.Next(g) do
		for i=val-ct,1,-1 do
			if c:IsCanAddCounter(COUNTER_ICE,i) then
				ct=ct+i
				if ct==val then
					return true
				end
				break
			end
		end
	end
	return false
end
function s.a_fil(c)
	if not (c:IsFaceup() and c:IsSpellTrapOnField() and c:IsAbleToHand()) then return false end
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	return g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_ICE),1,math.min(#g,2),2)
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local exc=aux.ActivateException(e)
		return chkc~=exc and chkc:IsOnField() and s.a_fil(chkc)
	end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.a_fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local g=Duel.SelectTarget(tp,s.a_fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	local fg=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,g)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,fg,1,COUNTER_ICE,2)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if tc and tc:IsRelateToChain() and #g>0 and g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_ICE),1,math.min(#g,2),2)
	and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and aux.PLChk(tc,tc:GetOwner(),LOCATION_HAND) then
		Duel.ShuffleHand(tc:GetControler())
		Duel.DistributeCounters(tp,COUNTER_ICE,2,g,id)
	end
end