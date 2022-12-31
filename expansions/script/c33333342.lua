--Novizia del Maestro dei Sigilli, Ayako
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:SummonedTrigger(false,true,true,false,0,CATEGORIES_SEARCH,true,true,
		nil,
		nil,
		aux.SearchTarget(aux.Filter(Card.IsSetCard,0x7ea),1,LOCATION_DECK+LOCATION_GRAVE),
		aux.SearchOperation(aux.Filter(Card.IsSetCard,0x7ea),LOCATION_DECK+LOCATION_GRAVE,0,1)
	)
	--add to hand
	c:FieldTrigger(nil,false,1,CATEGORY_ATKCHANGE,true,EVENT_ENGAGE,LOCATION_MZONE,nil,
		nil,
		nil,
		s.entg,
		s.enop
	)
end
function s.filter(c,tp)
	return c:IsEngaged() and c:IsMonster() and c:IsSetCard(0x7eb)
		and (c:IsCanUpdateEnergy(1,tp,REASON_EFFECT) or c:IsCanUpdateEnergy(-1,tp,REASON_EFFECT))
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=eg:Filter(s.filter,nil,tp)
	if chk==0 then return #en==1 and rp==tp end
	Duel.SetTargetCard(en:GetFirst())
	local c=e:GetHandler()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation())
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsEngaged() then
		local b1=tc:IsCanUpdateEnergy(1,tp,REASON_EFFECT)
		local b2=tc:IsCanUpdateEnergy(-1,tp,REASON_EFFECT)
		if not b1 and not b2 then return end
		local opt=aux.Option(id,tp,2,b1,b2)
		if not opt then return end
		local ct = (opt==0) and 1 or -1
		local e1,diff=tc:UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler())
		if not tc:IsImmuneToEffect(e1) and diff*ct>0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsFaceup() then
				c:UpdateATK(500,true)
			end
		end
	end
end