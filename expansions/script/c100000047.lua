--created by Swag, coded by XGlitchy30
--The Dreamy Forest's Happy Space
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddDoubleSidedProc(c,SIDE_OBVERSE,id+1)
	c:Activate()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(aux.EndPhaseCond(0))
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	Set 1 "Dreamy Forest" or "Dreary Forest" Spell/Trap, OR 1 "In the Forest, Black As My Memory", directly from your Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond())
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TRANSFORMED)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetCondition(aux.PreTransformationCheckSuccess)
	e3:SetTarget(aux.IsCanTransformTargetFunction)
	e3:SetOperation(aux.TransformOperationFunction(SIDE_REVERSE))
	c:RegisterEffect(e3)
	aux.AddPreTransformationCheck(c,e3,s.tfcon)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:GetHandler():IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.tdfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_DREAMY_FOREST) and not c:IsPublic() and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,c)
end
function s.setfilter(c)
	return ((c:IsST() and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST)) or c:IsCode(CARD_IN_THE_FOREST_BLACK_AS_MY_MEMORY)) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(g)
		Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.ShuffleIntoDeck(tc)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end
function s.tffilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(ARCHE_DREAMY_FOREST)
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tffilter,1,nil,tp)
end
