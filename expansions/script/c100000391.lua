--[[
Voidictator Servant - Eye of Corvus
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[When your opponent activates a card or effect from their hand or GY (Quick Effect): You can Tribute this card from your hand or face-up field; negate the activation, and if you do, apply 1 of
	the following effects, depending on where this card was Tributed.
	● Hand: Both players must banish 1 random card from their hand, then draw 1 card.
	● Field: Both players must banish 1 card each from their field and GYs (if possible).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(
		s.negcon,
		aux.DummyCost,
		s.negtg,
		s.negop
	)
	c:RegisterEffect(e1)
	--[[If this card is banished because of a "Voidictator" card you own, except "Voidictator Servant - Eye of Corvus": You can target 1 of your other banished "Voidictator" cards; add it to your
	hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetSendtoFunctions(LOCATION_HAND,TGCHECK_IT,aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR),LOCATION_REMOVED,0,1,1,true)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and p==1-tp and loc&(LOCATION_HAND|LOCATION_GRAVE)>0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:IsCostChecked() and c:IsReleasable() end
	local loc=c:GetLocation()
	Duel.SetTargetParam(loc)
	Duel.Release(c,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if loc==LOCATION_HAND then
		e:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	elseif loc&LOCATION_ONFIELD>0 then
		e:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD|LOCATION_GRAVE)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local step=0
		local tab={Group.CreateGroup(),Group.CreateGroup()}
		local loc=Duel.GetTargetParam()
		if loc==LOCATION_HAND then
			local drawp={false,false}
			while step<=2 do
				for p in aux.TurnPlayers() do
					if step==0 then
						local hg=Duel.GetHand(p)
						if hg:IsExists(Card.IsAbleToRemove,1,nil,p,POS_FACEUP,REASON_RULE) then
							local rg=hg:RandomSelect(p,1)
							if #rg>0 then
								tab[p+1]:Merge(rg)
							end
						end
					
					elseif step==1 then
						local rg=tab[p+1]
						if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_RULE,p)>0 then
							drawp[p+1]=true
						end
					
					elseif step==2 then
						if drawp[p+1]==true then
							Duel.Draw(p,1,REASON_EFFECT)
						end
					end
				end
				step=step+1
			end
			
		elseif loc&LOCATION_ONFIELD>0 then
			while step<=1 do
				for p in aux.TurnPlayers() do
					if step==0 then
						local hg=Duel.Group(aux.Necro(Card.IsAbleToRemove),p,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,p,POS_FACEUP,REASON_RULE)
						if hg:GetClassCount(Card.GetLocation)>1 then
							local rg=xgl.SelectUnselectGroup(hg,e,tp,2,2,xgl.dloccheck_field,1,p,HINTMSG_REMOVE)
							if #rg>0 then
								tab[p+1]:Merge(rg)
							end
						end
						
					elseif step==1 then
						local rg=tab[p+1]
						if Duel.Highlight(rg) then
							Duel.Remove(rg,POS_FACEUP,REASON_RULE,p)
						end
					end
				end
				step=step+1
			end
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if not (rc and rc:IsOwner(tp)) then return false end
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid,code1,code2=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		if rc:IsRelateToChain(ch) then
			return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
		else
			return s.TriggeringSetcode[cid] and code1~=id and (not code2 or code2~=id)
		end
	else
		return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
	end
end