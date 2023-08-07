--MMS - Vlad Dracula
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_MMS),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	c:EnableReviveLimit()
	--If this card is Special Summoned: You can target 1 monster your opponent controls; gain LP equal to half its ATK, then this card gains ATK equal to half that monster's ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--(Quick Effect): You can target 1 face-up card your opponent controls; negate its effects, until the end of the turn.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,nil,s.distg,s.disop)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local val=math.floor(g:GetFirst():GetAttack()/2)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	local c=e:GetHandler()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),val)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:HasAttack() then
		local val=math.floor(tc:GetAttack()/2)
		if Duel.Recover(tp,val,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsFaceup() and c:HasAttack() then
				Duel.BreakEffect()
				c:UpdateATK(val,true,c)
			end
		end
	end
end

--E2
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.Negate(tc,e)
	end
end