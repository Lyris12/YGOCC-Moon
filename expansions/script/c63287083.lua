--Totem Maledetti del Mondo Antico
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	e3:SetLabel(0,id)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--chain register
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3x:SetCode(EVENT_CHAINING)
	e3x:SetRange(LOCATION_FZONE)
	e3x:SetLabelObject(e3)
	e3x:SetOperation(s.regop)
	c:RegisterEffect(e3x)
	if not s.original_property then
		s.original_property={}
	end
	if not s.original_property[e3] then
		s.original_property[e3]=e3:GetProperty()
	end
end
function s.filter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) or not Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_DECK,1,nil,1-tp) then return end
	local g=Group.CreateGroup()
	for p=tp,1-tp,1-2*tp do
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(p,s.filter,p,LOCATION_DECK,0,1,1,nil,p)
		if #sg>0 then
			g:Merge(sg)
		end
	end
	if #g==2 then
		for p=tp,1-tp,1-2*tp do
			local sg1=g:Filter(Card.IsControler,nil,p)
			if #sg1==1 then
				g:RemoveCard(sg1:GetFirst())
				Duel.Search(sg1,1-p)
			end
		end
	end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local l1,l2=re:GetLabel()
	if rc and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and (not l2 or l2~=id) then
		rc:RegisterFlagEffect(id+100,RESET_CHAIN,0,1)
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:AddCard(rc)
		g:Remove(function(c) return c:GetFlagEffect(id+100)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		if Duel.GetFlagEffect(tp,id+100)==0 then
			Duel.RegisterFlagEffect(tp,id+100,RESET_CHAIN,0,1)
			Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,0,rp,rc:GetControler(),0)
			Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,0,rp,1-rc:GetControler(),0)
		end
	end
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then
		Duel.ResetFlagEffect(tp,id+100)
		for tc in aux.Next(g) do
			tc:ResetFlagEffect(id+100)
		end
		return g:IsExists(Card.IsControler,1,nil,tp)
	end
	e:SetProperty(s.original_property[e])
	g=g:Filter(Card.IsControler,nil,tp)
	local b1, b2, b3 = g:IsExists(Card.IsType,1,nil,TYPE_MONSTER), g:IsExists(Card.IsType,1,nil,TYPE_SPELL), g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
	if not b1 and not b2 and not b3 then return end
	local opt=aux.Option(id,tp,2,b1,b2,b3)
	if opt==1 then
		e:SetCategory(0)
		e:SetProperty(e:GetProperty()|EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(-800)
	elseif opt==2 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	elseif opt==0 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
	Duel.RegisterFlagEffect(tp,id+Duel.GetCurrentChain(),RESET_CHAIN,0,1,opt)
end
function s.chop(e,tp)
	if not e:GetHandler():IsRelateToChain() or Duel.GetFlagEffect(tp,id+Duel.GetCurrentChain())==0 then return end
	local opt=Duel.GetFlagEffectLabel(tp,id+Duel.GetCurrentChain())
	if opt==1 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.SetLP(p,math.max(Duel.GetLP(p)+d,0))
	elseif opt==2 then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
		if #g==0 then return end
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	elseif opt==0 then
		local g=Duel.GetDecktopGroup(tp,1):Filter(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
		if #g==0 then return end
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end