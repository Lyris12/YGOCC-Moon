--Dolorosa Scelta della Coppa
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(aux.TurnPlayerCond(1))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2)
	local b2 = Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) and Duel.IsPlayerCanDraw(1-tp,2)
	if chk==0 then return b1 and b2 end
	e:SetCategory(0)
	local g=Group.CreateGroup()
	for p=tp,1-tp,1-2*tp do
		local hint = (p==tp) and HINTMSG_CONTROL or HINTMSG_DESTROY
		local filt = (p==tp) and Card.IsControlerCanBeChanged or aux.TRUE
		Duel.Hint(HINT_SELECTMSG,p,hint)
		local sg=Duel.SelectMatchingCard(p,filt,p,0,LOCATION_MZONE,1,1,g)
		if #sg>0 then
			Duel.HintSelection(sg)
			g:AddCard(sg:GetFirst())
		end
	end
	if #g~=2 then return end
	local opt=aux.Option(id,1-tp,1,b1,b2)
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		local sg=g:Filter(Card.IsControler,nil,tp)
		Duel.SetTargetCard(sg:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif opt==1 then
		e:SetCategory(CATEGORY_CONTROL+CATEGORY_DRAW)
		local sg=g:Filter(Card.IsControler,nil,1-tp)
		Duel.SetTargetCard(sg:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
	end
end
function s.activate(e,tp)
	local opt=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain(0) then return end
	if opt==0 then
		if not tc:IsControler(tp) then return end
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	elseif opt==1 then
		if not tc:IsControler(1-tp) then return end
		if Duel.GetControl(tc,tp)~=0 then
			Duel.BreakEffect()
			Duel.Draw(1-tp,2,REASON_EFFECT)
		end
	end
end