--Cyber Plasma
function c249001131.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetValue(SUMMON_VALUE_SELF)
	e2:SetCondition(c249001131.spcon)
	e2:SetOperation(c249001131.spop)
	c:RegisterEffect(e2)
	--equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(518)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c249001131.eqtg)
	e3:SetOperation(c249001131.eqop)
	c:RegisterEffect(e3)
	--disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetCondition(c249001131.econ)
	c:RegisterEffect(e4)
	--immune
	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(c249001131.econ)
	e5:SetValue(c249001131.efilter)
    c:RegisterEffect(e5)
	--skip
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(1,0)
	e6:SetCondition(c249001131.econ)
	e6:SetCode(EFFECT_SKIP_DP)
	c:RegisterEffect(e6)
	--to deck
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,249001131)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCondition(c249001131.tdcon)
	e7:SetTarget(c249001131.tdtg)
	e7:SetOperation(c249001131.tdop)
	c:RegisterEffect(e7)
end
function c249001131.rfilter(c,tp)
	return c:IsSetCard(0x1093) and (c:IsControler(tp) or c:IsFaceup())
end
function c249001131.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
function c249001131.rmzfilter(c,tp)
	return c:IsSetCard(0x1093) and c:IsControler(tp) and c:GetSequence()<5
end
function c249001131.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	return ft>-3 and rg:GetCount()>2 and rg:IsExists(c249001131.rfilter,1,nil,tp)
		and (ft>0 or rg:IsExists(c249001131.mzfilter,ct,nil,tp))
		and (ft>-2 or rg:IsExists(c249001131.rmzfilter,1,nil,tp))
end
function c249001131.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		g=rg:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1093)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		g=rg:FilterSelect(tp,c249001131.rmzfilter,1,1,nil,tp)
	end
	local tc=g:GetFirst()
	if tc:IsControler(tp) and tc:GetSequence()<5 then ft=ft+1 end
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g2=rg:Select(tp,2,2,tc)
		g:Merge(g2)
	elseif ft>-1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g2=rg:FilterSelect(tp,c249001131.mzfilter,1,1,tc,tp)
		g:Merge(g2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g3=rg:Select(tp,1,1,g)
		g:Merge(g3)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g2=rg:FilterSelect(tp,c249001131.mzfilter,2,2,tc,tp)
		g:Merge(g2)
	end
	Duel.Release(g,REASON_COST)
end
function c249001131.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c249001131.eqlimit(e,c)
	return e:GetOwner()==c
end
function c249001131.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			if not Duel.Equip(tp,tc,c,true) then return end
			local atk=tc:GetTextAttack()/2
			if atk<0 then atk=0 end
			--Add Equip limit
			tc:RegisterFlagEffect(249001131,RESET_EVENT+RESETS_STANDARD,0,0)
			e:SetLabelObject(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c249001131.eqlimit)
			tc:RegisterEffect(e1)
			if atk>0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
			if tc:IsFaceup() then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_ADJUST)
				e3:SetRange(LOCATION_SZONE)	
				e3:SetOperation(c249001131.operation)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	end
end
function c249001131.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=e:GetHandler():GetEquipTarget()
	local code=c:GetOriginalCode()
	if eq:IsFaceup() and eq:GetFlagEffect(code)==0 then
		eq:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+EVENT_CHAINING,1)
		eq:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD+EVENT_CHAINING,0,1) 	
	end	
end
function c249001131.econ(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(e:GetHandlerPlayer(),1)
	return g and g:GetCount()>0 and g:GetFirst():IsFaceup()
end
function c249001131.efilter(e,te)
	return (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP)) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c249001131.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c249001131.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsAbleToDeck() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function c249001131.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT) then
		tc:ReverseInDeck()
	end
end