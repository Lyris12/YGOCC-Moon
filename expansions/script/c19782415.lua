--Codice Amministrale - Tenacia Efesiana
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Activate()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd7c))
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--shuffle
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.indval(e,re,r,rp)
	if r&REASON_BATTLE~=0 then
		return 1
	else
		return 0
	end
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():GetPreviousSequence()<5 and re:IsHasType(0x7e0)
		and (re:GetHandler():IsSetCard(0xd7c) or re:GetHandler():IsCode(19782405))
end
function s.filter(c,p)
	return c:GlitchyGetColumnGroup(1,1,true):IsExists(s.tdfilter,1,nil,p)
end
function s.tdfilter(c,p)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(p) and c:IsAbleToDeck()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck()
		else
			return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc,1-tp)
		end
	end
	if chk==0 then
		return true
	end
	local rc=re:GetHandler()
	local b1 = (rc:IsSetCard(0xd7c) and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil))
	local b2 = (rc:IsCode(19782405) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil,1-tp))
	local opt=aux.Option(id,tp,1,b1,b2)
	e:SetLabel(opt)
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil,1-tp)
		local sg=g:GetFirst():GlitchyGetColumnGroup(1,1,true):Filter(s.tdfilter,nil,1-tp)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		if e:GetLabel()==0 then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			local sg=tc:GlitchyGetColumnGroup(1,1,true):Filter(s.tdfilter,nil,1-tp)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end