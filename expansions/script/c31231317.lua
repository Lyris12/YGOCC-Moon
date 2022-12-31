--Olin Jerrik, Fleet Cascad
--Script by XGlitchy30
function c31231317.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),8,5)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c31231317.efilter)
	c:RegisterEffect(e1)
	--column destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31231317,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31231317)
	e2:SetCost(c31231317.clcost)
	e2:SetTarget(c31231317.cltg)
	e2:SetOperation(c31231317.clop)
	c:RegisterEffect(e2)
	--banish deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31231317,7))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31231317.rmcon)
	e3:SetTarget(c31231317.rmtg)
	e3:SetOperation(c31231317.rmop)
	c:RegisterEffect(e3)
end
local pack={}
	pack[1]={
		31231300
	}
	pack[2]={
		31231200
	}
--column checks
function c31231317.left(c,tp)
	return c:GetSequence()==0 and c:IsControler(1-tp)
end
function c31231317.mdleft(c,tp)
	return c:GetSequence()==1 and c:IsControler(1-tp)
end
function c31231317.middle(c,tp)
	return c:GetSequence()==2 and c:IsControler(1-tp)
end
function c31231317.mdright(c,tp)
	return c:GetSequence()==3 and c:IsControler(1-tp)
end
function c31231317.right(c,tp)
	return c:GetSequence()==4 and c:IsControler(1-tp)
end
function c31231317.adjacent(c,g,p)
	return g:IsContains(c) and c:GetSequence()<=4 and c:IsControler(p)
end
--filters
function c31231317.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
function c31231317.matcheck(c)
	return c:IsSetCard(0x3233) and c:IsType(TYPE_MONSTER)
end
function c31231317.check(c)
	return c:GetSequence()<=5
end
function c31231317.rmfilter(c,p)
	return c:IsFaceup() and c:IsSetCard(0x3233) and c:IsLevelBelow(4) and c:IsControler(p)
end
--column destruction
function c31231317.clcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c31231317.cltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return 
		Duel.IsExistingMatchingCard(c31231317.check,tp,0,LOCATION_ONFIELD,1,nil)
	 end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31231317,1))
	op=Duel.SelectOption(tp,aux.Stringid(31231317,2),aux.Stringid(31231317,3),aux.Stringid(31231317,4),aux.Stringid(31231317,5),aux.Stringid(31231317,6))
	e:SetLabel(op)
	--column response check
	if op==0 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.left,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),0)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	elseif op==1 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.mdleft,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),1)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local adj=g1:GetFirst():GetColumnGroup(1,1)
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	elseif op==2 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.middle,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),2)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	elseif op==3 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.mdright,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),3)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	elseif op==4 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.right,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),4)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	else return end
	----------------
end
function c31231317.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	if seq==0 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.left,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),0)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)
		end
	elseif seq==1 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.mdleft,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),1)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)
		end
	elseif seq==2 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.middle,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),2)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)
		end
	elseif seq==3 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.mdright,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),3)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)
		end
	elseif seq==4 then
		local adj=nil
		local g1=Duel.GetMatchingGroup(c31231317.right,tp,0,LOCATION_ONFIELD,nil,tp)
		if g1:GetCount()<=0 then
			local marker=Group.CreateGroup()
			local cpack=pack[1]
			local mk=cpack[math.random(#cpack)]
			marker:AddCard(Duel.CreateToken(tp,mk))
			Duel.MoveToField(marker:GetFirst(),tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(marker:GetFirst(),4)
			adj=marker:GetFirst():GetColumnGroup(1,1)
			Duel.Exile(marker:GetFirst(),REASON_RULE)
		else
			adj=g1:GetFirst():GetColumnGroup(1,1)
		end
		local g2=Duel.GetMatchingGroup(c31231317.adjacent,tp,0,LOCATION_ONFIELD,nil,adj,1-tp)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)
		end
	else return end
end
--banish deck
function c31231317.rmcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(c31231317.matcheck,1,nil)
end
function c31231317.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local od=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	local ct=Duel.GetMatchingGroupCount(c31231317.rmfilter,tp,LOCATION_REMOVED,0,nil,tp)
	if ct>od then return end
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0
		and tg:FilterCount(Card.IsAbleToRemove,nil)==ct end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
function c31231317.rmop(e,tp,eg,ep,ev,re,r,rp)
	local od=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	local ct=Duel.GetMatchingGroupCount(c31231317.rmfilter,tp,LOCATION_REMOVED,0,nil,tp)
	if ct==0 then return end
	if ct>od then return end
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	Duel.DisableShuffleCheck()
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end