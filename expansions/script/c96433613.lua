--	M   M	EEEEE	TTTTT	EEEEE	 OOO 	RRRR 	IIIII	TTTTT	EEEEE
--	MM MM	EE		  T		EE		O   O	RR  R	 III 	  T  	EE
--	M M M	EEEEE	  T		EEEEE	O   O	RRRR 	 III	  T		EEEEE
--	M   M	EE		  T		EE		O   O	RR  R	 III	  T		EE
--	M   M	EEEEE     T		EEEEE	 OOO 	RR  R	IIIII	  T		EEEEE

--Scripted by: XGlitchy30

local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--Activate
--Filters--
function cid.checkfilter(c,e)
	return c:IsDestructable(e)
end
-----------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_SZONE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local first_act=true
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_SZONE,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	local chkg=g:Filter(cid.checkfilter,nil,e)
	while #g>0 do
		Duel.SetLP(tp,Duel.GetLP(tp)-2000)
		if Duel.GetLP(tp)<=0 then return end
		if #chkg>0 or first_act then
			Duel.BreakEffect()
			first_act=false
			if #g<=0 then return end
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
				g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_SZONE,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
				chkg=g:Filter(cid.checkfilter,nil,e)
			end
		else
			return
		end
	end
end