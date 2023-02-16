--Fixis, Hollohom Wrath
local ref,id=GetID()
xpcall(function() require("expansions/script/Hollohom") end,function() require("script/Hollohom") end)
function ref.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixRep(c,true,true,ref.ffilter,2,4)
	local fe=aux.AddContactFusionProcedure(c,ref.contactfilter,LOCATION_EXTRA,0,Duel.SendtoGrave,REASON_COST)
	fe:SetCountLimit(1,id)
	--Botdeck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(ref.tdtg)
	e1:SetOperation(ref.tdop)
	c:RegisterEffect(e1)
end
function ref.matct(tp)
	local ct=4
	if not Duel.IsExistingMatchingCard(ref.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil) then ct=ct-1 end
	if Duel.IsExistingMatchingCard(ref.fieldfilter,tp,0,LOCATION_ONFIELD,1,nil) then ct=ct-1 end
	Debug.Message(ct)
	return ct
end
function ref.ffilter(c,fc,sub,mg,sg)
	if not c:IsFusionSetCard(Hollohom.Code) then return false end
	if not sg then return true end
	local tp=fc:GetControler()
	local ct=ref.matct(tp)
	return #sg==ct --or #mg>ct
end
function ref.fieldfilter(c) return c:IsType(TYPE_FIELD) and c:IsFaceup() end
function ref.contactfilter(c,fc) return c:IsFaceup() and c:IsAbleToGraveAsCost() end

function ref.adjmats(e)
	local mt=getmetatable(e:GetHandler())
	local ct=ref.matct(e:GetHandlerPlayer())
	mt.material_count={ct,ct}
end

--Botdeck
function ref.tdfilter(c,e) return Hollohom.Is(c) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) end
function ref.tdfilter2(c,e) return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) end
function ref.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil,e)
		and Duel.IsExistingTarget(ref.tdfilter2,tp,0,LOCATION_GRAVE,2,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil,e)
	local g2=Duel.SelectMatchingCard(tp,ref.tdfilter2,tp,0,LOCATION_GRAVE,2,2,nil,e)
	g:Merge(g2)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function ref.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=4 then
		local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g2:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
